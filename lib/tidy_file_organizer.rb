require 'tidy_file_organizer/version'
require 'tidy_file_organizer/file_helper'
require 'tidy_file_organizer/file_mover'
require 'tidy_file_organizer/config'
require 'tidy_file_organizer/setup_prompt'
require 'tidy_file_organizer/organizer'
require 'tidy_file_organizer/date_organizer'
require 'tidy_file_organizer/duplicate_display'
require 'tidy_file_organizer/duplicate_detector'
require 'tidy_file_organizer/cli'

module TidyFileOrganizer
  class Error < StandardError; end
end
