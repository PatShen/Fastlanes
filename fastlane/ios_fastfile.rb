# fastlane_version "2.175.0"
#
# default_platform :ios

ENV["FASTLANE_XCODEBUILD_SETTINGS_TIMEOUT"] = "30"
ENV["FASTLANE_XCODEBUILD_SETTINGS_RETRIES"] = "20"


platform :ios do
  # https://docs.fastlane.tools/actions/match/#match
  GIT_URL = "Match import git URL"

  # desc '在最前执行...'
  # before_each do |options|
  #   # build 号自动 +1
  #   increment_build_number
  #   git_add(path: "*.xcodeproj", shell_escape: false)
  #   reset_git_repo(
  #     files: ["*/Info.plist"],
  #     skip_clean: true,
  #     force: true,
  #   )
  #   commit_version_bump(
  #     message: "CI update build version",
  #     force: true
  #   )
  #   push_to_git_remote(
  #     tags: false
  #   )
  # end

  desc '打Debug包'
  lane :tc_ios_package_debug do |options|
    repoName = options[:repo]
    scheme = options[:scheme]
    output = options[:output_dir]

    path = "#{output}/#{scheme}.ipa"
    tc_clean_build(path: path)

    tc_pod_install(repo: repoName)

    match(
      git_url: GIT_URL,
      type: "development",
      readonly: true
    )

    gym(
      # 在构建前先clean
      clean: true,
      # 隐藏没有必要的信息
      silent: true,
      # 指定打包所使用的输出方式 (可选: app-store, package, ad-hoc, enterprise, development)
      export_method: "development",
      # 指定项目的 scheme 名称
      scheme: scheme,
      # 指定输出的文件夹地址
      output_directory: output,
      # 指定打包方式 (可选: Release, Debug)
      configuration: "Debug",
    )

  end

  desc '打adhoc包'
  lane :tc_ios_package_adhoc do |options|
    repoName = options[:repo]
    scheme = options[:scheme]
    output = options[:output_dir]

    path = "#{output}/#{scheme}.ipa"
    tc_clean_build(path: path)

    tc_pod_install(repo: repoName)

    match(
      git_url: GIT_URL,
      type: "adhoc",
      readonly: true
    )

    gym(
      # 在构建前先clean
      clean: true,
      # 隐藏没有必要的信息
      silent: true,
      # 指定打包所使用的输出方式 (可选: app-store, package, adhoc, enterprise, development)
      export_method: "ad-hoc",
      # 指定项目的 scheme 名称
      scheme: scheme,
      # 指定输出的文件夹地址
      output_directory: output,
      # 指定打包方式 (可选: Release, Debug)
      configuration: "Release",
    )
  end

  desc '打enterprise包'
  lane :tc_ios_package_enterprice do |options|
    repoName = options[:repo]
    scheme = options[:scheme]
    output = options[:output_dir]
    path = "#{output}/#{scheme}.ipa"
    tc_clean_build(path: path)

    tc_pod_install(repo: repoName)

    match(
      git_url: GIT_URL,
      type: "enterprise",
      readonly: true
    )

    gym(
      # 在构建前先clean
      clean: true,
      # 隐藏没有必要的信息
      silent: true,
      # 指定打包所使用的输出方式 (可选: app-store, package, ad-hoc, enterprise, development)
      export_method: "enterprise",
      # 指定项目的 scheme 名称
      scheme: scheme,
      # 指定输出的文件夹地址
      output_directory: output,
      # 指定打包方式 (可选: Release, Debug)
      configuration: "Release",
    )
  end

  desc '打appstore包'
  lane :tc_ios_package_appstore do |options|
    repoName = options[:repo]
    scheme = options[:scheme]
    output = options[:output_dir]

    path = "#{output}/#{scheme}.ipa"
    tc_clean_build(path: path)

    tc_pod_install(repo: repoName)

    match(
      git_url: GIT_URL,
      type: "appstore",
      readonly: true
    )

    gym(
      # 在构建前先clean
      clean: true,
      # 隐藏没有必要的信息
      silent: true,
      # 指定打包所使用的输出方式 (可选: app-store, package, adhoc, enterprise, development)
      export_method: "app-store",
      # 指定项目的 scheme 名称
      scheme: scheme,
      # 指定输出的文件夹地址
      output_directory: output,
      # 指定打包方式 (可选: Release, Debug)
      configuration: "Release",
    )

  end
end
