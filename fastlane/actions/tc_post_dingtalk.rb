module Fastlane
  module Actions
    module SharedValues
      TC_POST_DINGTALK_CUSTOM_VALUE = :TC_POST_DINGTALK_CUSTOM_VALUE
    end

    require 'cgi'
    require 'json'
    require 'net/http'
    require 'uri'
    require 'openssl'
    require 'Base64'

    # 打包机器人测试
    ROBOT_1_SECRET = "SEC2f215df7da9b156aaad8bc99369549acc1ee46a43cdff03be66435516f48abda"
    ROBOT_1_URL = "https://oapi.dingtalk.com/robot/send?access_token=4f89bd1cb71735563d211d9931c109a7f9d9671aa57ed79b9ffffae79f139c8d"
    # 给测试发包群
    ROBOT_2_SECRET = "SEC1edaf57d7f1085370f68a17abfff2a227e714de2e411c17a4ff834771e459289"
    ROBOT_2_URL = "https://oapi.dingtalk.com/robot/send?access_token=3cb8843ab8fd33c8bcbf8a0ef033aa0c74c570afdcf4c07081248babfe85b1cd"

    class TcPostDingtalkAction < Action
      def self.run(params)
        # fastlane will take care of reading in the parameter and fetching the environment variable:
        msgtype = params[:msg_type]
        title = params[:title]
        text = params[:text]

        postMsgRobot1(msgtype, title, text)
        # postMsgRobot2(msgtype, title, text)
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.postMessage(webhook, msgtype, title, text)
        header = {
          "content-type" => "application/json",
          "Charset" => "UTF-8"
        }

        content = {
          "title" => title,
          "text" => text
        }
        message = {
          "msgtype" => msgtype,
          msgtype => content
        }

        #application/json
        url = URI(webhook)

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        # 设置请求参数
        data = message.to_json

        response = https.post(url, data, header)
        puts response.body

      end

      def self.dingtalkRobotWebhook(secret, robotURL)
        timestamp = (Time.now.to_f * 1000).to_i
        sign = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), secret, "#{timestamp}\n#{secret}")).strip
        webhook = "#{robotURL}&timestamp=#{timestamp}&sign=#{sign}"
        return webhook
      end

      def self.postMsgRobot1(msgtype, title, text)
        webhook = dingtalkRobotWebhook(ROBOT_1_SECRET, ROBOT_1_URL)
        postMessage(webhook, msgtype, title, text)
      end

      def self.postMsgRobot2(msgtype, title, text)
        webhook = dingtalkRobotWebhook(ROBOT_2_SECRET, ROBOT_2_URL)
        postMessage(webhook, msgtype, title, text)
      end

      def self.description
        "发送钉钉消息"
      end

      def self.details
        # Optional:
        # this is your chance to provide a more detailed description of this action
        "用法：tc_post_dingtalk(msg_type: 消息类型(markdown/text等), title: 显示在聊天列表的摘要, text:消息正文)"
      end

      def self.available_options
        # Define all options your action supports.

        # Below a few examples
        [
          FastlaneCore::ConfigItem.new(key: :msg_type,
                                       # env_name: "FL_TC_POST_DINGTALK_API_TOKEN", # The name of the environment variable
                                       description: "消息类型：markdown/text等", # a short description of this parameter
                                       verify_block: proc do |value|
                                          UI.user_error!("请提供消息类型") unless (value and not value.empty?)
                                          # UI.user_error!("Couldn't find file at path '#{value}'") unless File.exist?(value)
                                       end),
           FastlaneCore::ConfigItem.new(key: :title,
                                        # env_name: "FL_TC_POST_DINGTALK_API_TOKEN", # The name of the environment variable
                                        description: "标题", # a short description of this parameter
                                        optional:true,
                                        is_string: false
                                        ),
            FastlaneCore::ConfigItem.new(key: :text,
                                         # env_name: "FL_TC_POST_DINGTALK_API_TOKEN", # The name of the environment variable
                                         description: "内容", # a short description of this parameter
                                         optional:true,
                                         is_string: false
                                       )
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
