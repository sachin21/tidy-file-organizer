require 'tidy_file_organizer'
require 'fileutils'
require 'tmpdir'

RSpec.describe TidyFileOrganizer::DuplicateDetector do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:detector) { described_class.new(tmp_dir) }

  after do
    FileUtils.remove_entry tmp_dir
  end

  describe '#find_duplicates' do
    context '重複ファイルが存在する場合' do
      before do
        # Create 3 files with same content
        @file1 = File.join(tmp_dir, 'file1.txt')
        @file2 = File.join(tmp_dir, 'file2.txt')
        @file3 = File.join(tmp_dir, 'file3.txt')
        @unique_file = File.join(tmp_dir, 'unique.txt')

        File.write(@file1, 'same content')
        File.write(@file2, 'same content')
        File.write(@file3, 'same content')
        File.write(@unique_file, 'different content')
      end

      it '重複ファイルを正しく検出する' do
        duplicates = detector.find_duplicates(recursive: false)

        expect(duplicates.size).to eq(1)

        # Files with same content are grouped
        duplicate_group = duplicates.values.first
        expect(duplicate_group).to contain_exactly(@file1, @file2, @file3)
      end
    end

    context '重複ファイルが存在しない場合' do
      before do
        File.write(File.join(tmp_dir, 'file1.txt'), 'content1')
        File.write(File.join(tmp_dir, 'file2.txt'), 'content2')
        File.write(File.join(tmp_dir, 'file3.txt'), 'content3')
      end

      it '空のハッシュを返す' do
        duplicates = detector.find_duplicates(recursive: false)
        expect(duplicates).to be_empty
      end
    end
  end

  describe '#remove_duplicates' do
    before do
      # Create duplicate files
      @file1 = File.join(tmp_dir, 'file1.txt')
      @file2 = File.join(tmp_dir, 'file2.txt')
      @file3 = File.join(tmp_dir, 'file3.txt')

      File.write(@file1, 'same content')
      File.write(@file2, 'same content')
      File.write(@file3, 'same content')
    end

    context 'Dry-run モードの場合' do
      it 'ファイルは削除されない' do
        output = capture_stdout { detector.remove_duplicates(dry_run: true, recursive: false, interactive: false) }

        expect(output).to include('[Dry-run]')
        expect(File.exist?(@file1)).to be true
        expect(File.exist?(@file2)).to be true
        expect(File.exist?(@file3)).to be true
      end
    end

    context 'Force モードの場合' do
      it '最初のファイルを残し、残りを削除する' do
        # Test with interactive mode disabled
        detector.remove_duplicates(dry_run: false, recursive: false, interactive: false)

        # Only 1 of 3 files remains
        existing_files = [@file1, @file2, @file3].select { |f| File.exist?(f) }
        expect(existing_files.size).to eq(1)

        # 2 files are deleted
        deleted_files = [@file1, @file2, @file3].reject { |f| File.exist?(f) }
        expect(deleted_files.size).to eq(2)
      end
    end

    context 'インタラクティブモードの場合' do
      before do
        # Create files with same content
        File.write(@file1, 'same content')
        File.write(@file2, 'same content')
        File.write(@file3, 'same content')
      end

      it 'yesを入力すると削除が実行される' do
        # Mock stdin
        allow($stdin).to receive(:gets).and_return("yes\n")

        output = capture_stdout { detector.remove_duplicates(dry_run: false, recursive: false, interactive: true) }

        expect(output).to include(TidyFileOrganizer::I18n.t('duplicate_detector.confirm_header'))
        expect(output).to include(TidyFileOrganizer::I18n.t('duplicate_detector.confirm_deletion'))
        expect(output).to include(TidyFileOrganizer::I18n.t('duplicate_detector.executing_deletion'))

        # Files are deleted
        existing_files = [@file1, @file2, @file3].select { |f| File.exist?(f) }
        expect(existing_files.size).to eq(1)
      end

      it 'noを入力すると削除がキャンセルされる' do
        # Mock stdin
        allow($stdin).to receive(:gets).and_return("no\n")

        output = capture_stdout { detector.remove_duplicates(dry_run: false, recursive: false, interactive: true) }

        expect(output).to include(TidyFileOrganizer::I18n.t('duplicate_detector.deletion_cancelled'))

        # Files are not deleted
        expect(File.exist?(@file1)).to be true
        expect(File.exist?(@file2)).to be true
        expect(File.exist?(@file3)).to be true
      end

      it '無効な入力の場合は削除がキャンセルされる' do
        # Mock stdin
        allow($stdin).to receive(:gets).and_return("maybe\n")

        output = capture_stdout { detector.remove_duplicates(dry_run: false, recursive: false, interactive: true) }

        expect(output).to include(TidyFileOrganizer::I18n.t('duplicate_detector.invalid_response'))

        # Files are not deleted
        expect(File.exist?(@file1)).to be true
        expect(File.exist?(@file2)).to be true
        expect(File.exist?(@file3)).to be true
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
