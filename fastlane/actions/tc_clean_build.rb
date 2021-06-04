module Fastlane
  module Actions
    module SharedValues
      TC_CLEAN_BUILD_CUSTOM_VALUE = :TC_CLEAN_BUILD_CUSTOM_VALUE
    end

    class TcCleanBuildAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        path = params[:path]
        if File::exists?( path )
          File.delete(path)
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "清除老包"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "清除老包\n使用方法：tc_clean_build(path: path)"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       # env_name: "FL_POD_REPO_UPDATE_API_TOKEN", # The name of the environment variable
                                       description: "需要删除的路径", # a short description of this parameter
                                       optional: false,
                                       is_string: true,
                                       verify_block: proc do |value|
                                          UI.user_error!("请提供需要删除的路径") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end)
        ]
      end

      def self.output
        # Define the shared values you are going to provide
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
        nil
      end

      def self.authors
        # So no one will ever forget your contribution to fastlane :) You are awesome btw!
        ["shenwenxin/shenwenxin@tospur.com"]
      end

      def self.is_supported?(platform)
        # you can do things like
        #
        #  true
        #
        #  platform == :ios
        #
        #  [:ios, :mac].include?(platform)
        #

        platform == :ios
      end
    end
  end
end
