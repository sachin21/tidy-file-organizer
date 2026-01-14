require 'tidy_file_organizer'
require 'fileutils'
require 'tmpdir'
require 'digest'

RSpec.describe TidyFileOrganizer::Organizer do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:organizer) { described_class.new(tmp_dir) }
  let(:config_dir) { File.expand_path('~/.config/tidy-file-organizer') }
  let(:config_file) { File.join(config_dir, "#{Digest::MD5.hexdigest(File.expand_path(tmp_dir))}.yml") }

  before do
    # 設定ディレクトリを作成
    FileUtils.mkdir_p(config_dir)
    # 既存のテスト用設定ファイルをクリーンアップ
    FileUtils.rm_f(config_file)
  end

  after do
    FileUtils.remove_entry tmp_dir
    FileUtils.rm_f(config_file)
  end

  describe '#determine_destination' do
    let(:config) do
      {
        extensions: { 'images' => ['jpg', 'png'], 'docs' => ['pdf'] },
        keywords: { 'work' => ['project_a', 'invoice'] }
      }
    end

    it '拡張子に基づいて正しいディレクトリを返す' do
      expect(organizer.send(:determine_destination, 'test.jpg', config)).to eq('images')
      expect(organizer.send(:determine_destination, 'doc.pdf', config)).to eq('docs')
    end

    it 'キーワードに基づいて正しいディレクトリを返す' do
      expect(organizer.send(:determine_destination, 'project_a_specification.txt', config)).to eq('work')
      expect(organizer.send(:determine_destination, 'my_invoice.png', config)).to eq('work') # キーワード優先
    end

    it '一致するものがない場合はnilを返す' do
      expect(organizer.send(:determine_destination, 'unknown.txt', config)).to be_nil
    end
  end

  describe '#run' do
    let(:config) do
      {
        extensions: { 'images' => ['jpg'] },
        keywords: { 'work' => ['project_a'] }
      }
    end

    before do
      # 設定ファイルを保存
      File.write(config_file, config.to_yaml)

      # テスト用ファイルを作成
      FileUtils.touch(File.join(tmp_dir, 'test.jpg'))
      FileUtils.touch(File.join(tmp_dir, 'project_a.txt'))
      FileUtils.touch(File.join(tmp_dir, 'other.txt'))
    end

    context 'Dry-run モードの場合' do
      it 'ファイルは移動されない' do
        expect { organizer.run(dry_run: true) }.to output(/\[Dry-run\]/).to_stdout
        expect(File.exist?(File.join(tmp_dir, 'test.jpg'))).to be true
        expect(Dir.exist?(File.join(tmp_dir, 'images'))).to be false
      end
    end

    context 'Force モード（実際に移動）の場合' do
      it 'ファイルが正しいディレクトリに移動される' do
        expect { organizer.run(dry_run: false) }.to output(/Moved:/).to_stdout

        expect(File.exist?(File.join(tmp_dir, 'images', 'test.jpg'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'work', 'project_a.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'other.txt'))).to be true # 整理対象外

        expect(File.exist?(File.join(tmp_dir, 'test.jpg'))).to be false
      end
    end

    context '再帰モードの場合' do
      before do
        # サブディレクトリとファイルを作成
        FileUtils.mkdir_p(File.join(tmp_dir, 'subdir1'))
        FileUtils.mkdir_p(File.join(tmp_dir, 'subdir2', 'nested'))

        FileUtils.touch(File.join(tmp_dir, 'subdir1', 'photo.jpg'))
        FileUtils.touch(File.join(tmp_dir, 'subdir2', 'project_a_doc.txt'))
        FileUtils.touch(File.join(tmp_dir, 'subdir2', 'nested', 'image.jpg'))
      end

      it 'サブディレクトリ内のファイルも整理される (Dry-run)' do
        output = capture_stdout { organizer.run(dry_run: true, recursive: true) }

        expect(output).to match(%r{subdir1/photo\.jpg})
        expect(output).to match(%r{subdir2/project_a_doc\.txt})
        expect(output).to match(%r{subdir2/nested/image\.jpg})
        expect(output).to match(/\[再帰モード\]/)
      end

      it 'サブディレクトリ内のファイルも実際に移動される (Force)' do
        organizer.run(dry_run: false, recursive: true)

        # ルート階層のファイルが移動される
        expect(File.exist?(File.join(tmp_dir, 'images', 'test.jpg'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'work', 'project_a.txt'))).to be true

        # サブディレクトリのファイルも移動される
        expect(File.exist?(File.join(tmp_dir, 'images', 'photo.jpg'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'work', 'project_a_doc.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'images', 'image.jpg'))).to be true

        # 元の場所にはない
        expect(File.exist?(File.join(tmp_dir, 'subdir1', 'photo.jpg'))).to be false
        expect(File.exist?(File.join(tmp_dir, 'subdir2', 'project_a_doc.txt'))).to be false
      end
    end
  end

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
