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
    # Create config directory
    FileUtils.mkdir_p(config_dir)
    # Clean up existing test config file
    FileUtils.rm_f(config_file)
  end

  after do
    FileUtils.remove_entry tmp_dir
    FileUtils.rm_f(config_file)
  end

  describe '#determine_destination' do
    let(:config) do
      {
        extensions: { 'images' => %w[jpg png], 'docs' => ['pdf'] },
        keywords: { 'work' => %w[project_a invoice] },
      }
    end

    it 'returns correct directory based on extension' do
      expect(organizer.send(:determine_destination, 'test.jpg', config)).to eq('images')
      expect(organizer.send(:determine_destination, 'doc.pdf', config)).to eq('docs')
    end

    it 'returns correct directory based on keyword' do
      expect(organizer.send(:determine_destination, 'project_a_specification.txt', config)).to eq('work')
      expect(organizer.send(:determine_destination, 'my_invoice.png', config)).to eq('work') # keyword takes priority
    end

    it 'returns nil when no match is found' do
      expect(organizer.send(:determine_destination, 'unknown.txt', config)).to be_nil
    end

    context 'when using pattern matching' do
      let(:config_with_patterns) do
        {
          extensions: { 'images' => %w[jpg png], 'docs' => ['pdf'] },
          keywords: { 'work' => %w[invoice] },
          patterns: {
            'ByDate' => [
              { 'pattern' => '\d{4}-\d{2}-\d{2}', 'description' => 'Date format: 2024-01-15' },
              { 'pattern' => '\d{8}', 'description' => 'Date format: 20240115' },
            ],
            'Versions' => [
              { 'pattern' => 'v\d+\.\d+\.\d+', 'description' => 'Semantic version: v1.0.0' },
              { 'pattern' => '_v\d+', 'description' => 'Version suffix: file_v2' },
            ],
          },
        }
      end

      it 'returns correct directory based on pattern (date format)' do
        expect(organizer.send(:determine_destination, 'report_2024-01-15.pdf', config_with_patterns)).to eq('ByDate')
        expect(organizer.send(:determine_destination, 'file_20240115.txt', config_with_patterns)).to eq('ByDate')
      end

      it 'returns correct directory based on pattern (version format)' do
        expect(organizer.send(:determine_destination, 'app_v1.0.0.zip', config_with_patterns)).to eq('Versions')
        expect(organizer.send(:determine_destination, 'document_v2.pdf', config_with_patterns)).to eq('Versions')
      end

      it 'prioritizes pattern matching over keywords' do
        # When pattern matches, it takes priority over keywords
        expect(organizer.send(:determine_destination, 'invoice_2024-01-15.pdf', config_with_patterns)).to eq('ByDate')
      end

      it 'falls back to keywords and extensions when pattern matching fails' do
        expect(organizer.send(:determine_destination, 'invoice.pdf', config_with_patterns)).to eq('work')
        expect(organizer.send(:determine_destination, 'photo.jpg', config_with_patterns)).to eq('images')
      end
    end

    context 'with Phase 1 new categories' do
      let(:config_with_new_categories) do
        {
          extensions: {
            'Databases' => %w[db sqlite sqlite3 sql],
            'Fonts' => %w[ttf otf woff woff2],
            'eBooks' => %w[epub mobi azw],
            'Logs' => %w[log out err],
            'Data' => %w[csv tsv parquet],
          },
          keywords: {
            'Receipts' => %w[receipt 領収書],
            'Reports' => %w[report レポート],
            'Templates' => %w[template sample],
          },
        }
      end

      it 'correctly classifies database files' do
        expect(organizer.send(:determine_destination, 'app.db', config_with_new_categories)).to eq('Databases')
        expect(organizer.send(:determine_destination, 'data.sqlite3', config_with_new_categories)).to eq('Databases')
      end

      it 'correctly classifies font files' do
        expect(organizer.send(:determine_destination, 'font.ttf', config_with_new_categories)).to eq('Fonts')
        expect(organizer.send(:determine_destination, 'style.woff2', config_with_new_categories)).to eq('Fonts')
      end

      it 'correctly classifies ebook files' do
        expect(organizer.send(:determine_destination, 'book.epub', config_with_new_categories)).to eq('eBooks')
        expect(organizer.send(:determine_destination, 'novel.mobi', config_with_new_categories)).to eq('eBooks')
      end

      it 'correctly classifies log files' do
        expect(organizer.send(:determine_destination, 'app.log', config_with_new_categories)).to eq('Logs')
        expect(organizer.send(:determine_destination, 'error.err', config_with_new_categories)).to eq('Logs')
      end

      it 'correctly classifies data files' do
        expect(organizer.send(:determine_destination, 'data.csv', config_with_new_categories)).to eq('Data')
        expect(organizer.send(:determine_destination, 'export.parquet', config_with_new_categories)).to eq('Data')
      end

      it 'correctly classifies files with new keywords' do
        expect(organizer.send(:determine_destination, 'receipt_jan.pdf', config_with_new_categories)).to eq('Receipts')
        expect(organizer.send(:determine_destination, 'report_q1.docx', config_with_new_categories)).to eq('Reports')
        expect(organizer.send(:determine_destination, 'template_email.txt', config_with_new_categories)).to eq('Templates')
      end
    end
  end

  describe '#run' do
    let(:config) do
      {
        extensions: { 'images' => ['jpg'] },
        keywords: { 'work' => ['project_a'] },
      }
    end

    before do
      # Save config file
      File.write(config_file, config.to_yaml)

      # Create test files
      FileUtils.touch(File.join(tmp_dir, 'test.jpg'))
      FileUtils.touch(File.join(tmp_dir, 'project_a.txt'))
      FileUtils.touch(File.join(tmp_dir, 'other.txt'))
    end

    context 'in dry-run mode' do
      it 'does not move files' do
        expect { organizer.run(dry_run: true) }.to output(/\[Dry-run\]/).to_stdout
        expect(File.exist?(File.join(tmp_dir, 'test.jpg'))).to be true
        expect(Dir.exist?(File.join(tmp_dir, 'images'))).to be false
      end
    end

    context 'in force mode (actual move)' do
      it 'moves files to correct directories' do
        expect { organizer.run(dry_run: false) }.to output(/Moved:/).to_stdout

        expect(File.exist?(File.join(tmp_dir, 'images', 'test.jpg'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'work', 'project_a.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'other.txt'))).to be true # not organized

        expect(File.exist?(File.join(tmp_dir, 'test.jpg'))).to be false
      end
    end

    context 'in recursive mode' do
      before do
        # Create subdirectories and files
        FileUtils.mkdir_p(File.join(tmp_dir, 'subdir1'))
        FileUtils.mkdir_p(File.join(tmp_dir, 'subdir2', 'nested'))

        FileUtils.touch(File.join(tmp_dir, 'subdir1', 'photo.jpg'))
        FileUtils.touch(File.join(tmp_dir, 'subdir2', 'project_a_doc.txt'))
        FileUtils.touch(File.join(tmp_dir, 'subdir2', 'nested', 'image.jpg'))
      end

      it 'organizes files in subdirectories (dry-run)' do
        output = capture_stdout { organizer.run(dry_run: true, recursive: true) }

        expect(output).to match(%r{subdir1/photo\.jpg})
        expect(output).to match(%r{subdir2/project_a_doc\.txt})
        expect(output).to match(%r{subdir2/nested/image\.jpg})
        expect(output).to include(TidyFileOrganizer::I18n.t('organizer.recursive_mode'))
      end

      it 'actually moves files in subdirectories (force)' do
        organizer.run(dry_run: false, recursive: true)

        # Root level files are moved
        expect(File.exist?(File.join(tmp_dir, 'images', 'test.jpg'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'work', 'project_a.txt'))).to be true

        # Subdirectory files are also moved
        expect(File.exist?(File.join(tmp_dir, 'images', 'photo.jpg'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'work', 'project_a_doc.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, 'images', 'image.jpg'))).to be true

        # Not in original location
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
