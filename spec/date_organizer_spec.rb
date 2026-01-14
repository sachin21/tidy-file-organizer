require 'tidy_file_organizer'
require 'fileutils'
require 'tmpdir'

RSpec.describe TidyFileOrganizer::DateOrganizer do
  let(:tmp_dir) { Dir.mktmpdir }
  let(:date_organizer) { described_class.new(tmp_dir) }

  after do
    FileUtils.remove_entry tmp_dir
  end

  describe '#organize_by_date' do
    before do
      # Create test files
      @file1 = File.join(tmp_dir, 'file1.txt')
      @file2 = File.join(tmp_dir, 'file2.txt')
      @file3 = File.join(tmp_dir, 'file3.txt')

      FileUtils.touch(@file1)
      FileUtils.touch(@file2)
      FileUtils.touch(@file3)

      # Set file modification times
      File.utime(Time.new(2023, 1, 15), Time.new(2023, 1, 15), @file1)
      File.utime(Time.new(2023, 6, 20), Time.new(2023, 6, 20), @file2)
      File.utime(Time.new(2024, 3, 10), Time.new(2024, 3, 10), @file3)
    end

    context 'with year pattern' do
      it 'organizes files by year (dry-run)' do
        output = capture_stdout { date_organizer.organize_by_date(pattern: 'year', dry_run: true) }

        expect(output).to include('[Dry-run]')
        expect(output).to include('file1.txt -> 2023/')
        expect(output).to include('file2.txt -> 2023/')
        expect(output).to include('file3.txt -> 2024/')

        # Files are not moved
        expect(File.exist?(@file1)).to be true
        expect(Dir.exist?(File.join(tmp_dir, '2023'))).to be false
      end

      it 'actually organizes files by year (force)' do
        date_organizer.organize_by_date(pattern: 'year', dry_run: false)

        expect(File.exist?(File.join(tmp_dir, '2023', 'file1.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, '2023', 'file2.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, '2024', 'file3.txt'))).to be true

        expect(File.exist?(@file1)).to be false
        expect(File.exist?(@file2)).to be false
        expect(File.exist?(@file3)).to be false
      end
    end

    context 'with year-month pattern' do
      it 'organizes files by year-month (force)' do
        date_organizer.organize_by_date(pattern: 'year-month', dry_run: false)

        expect(File.exist?(File.join(tmp_dir, '2023-01', 'file1.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, '2023-06', 'file2.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, '2024-03', 'file3.txt'))).to be true
      end
    end

    context 'with year-month-day pattern' do
      it 'organizes files by year-month-day (force)' do
        date_organizer.organize_by_date(pattern: 'year-month-day', dry_run: false)

        expect(File.exist?(File.join(tmp_dir, '2023-01-15', 'file1.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, '2023-06-20', 'file2.txt'))).to be true
        expect(File.exist?(File.join(tmp_dir, '2024-03-10', 'file3.txt'))).to be true
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
