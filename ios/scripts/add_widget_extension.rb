#!/usr/bin/env ruby
# Adds VoclioWidgetExtension target to Runner.xcodeproj

require 'xcodeproj'

project_path = File.expand_path('../Runner.xcodeproj', __dir__)
project = Xcodeproj::Project.open(project_path)

extension_name = 'VoclioWidgetExtension'
widget_group_name = 'VoclioWidget'

if project.targets.any? { |t| t.name == extension_name }
  puts "Target #{extension_name} already exists"
  exit 0
end

runner = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner target not found' unless runner

# Widget extension target
extension_target = project.new_target(
  :app_extension,
  extension_name,
  :ios,
  '14.0'
)

extension_target.product_type = 'com.apple.product-type.app-extension'

# Groups
widget_group = project.main_group.new_group(widget_group_name, widget_group_name)

swift_ref = widget_group.new_file('VoclioWidget.swift')
info_ref = widget_group.new_file('Info.plist')
assets_ref = widget_group.new_file('Assets.xcassets')

extension_target.source_build_phase.add_file_reference(swift_ref)
extension_target.resources_build_phase.add_file_reference(assets_ref)

# Embed extension in Runner
copy_phase = runner.copy_files_build_phases.find { |p| p.name == 'Embed Foundation Extensions' }
unless copy_phase
  copy_phase = project.new(Xcodeproj::Project::Object::PBXCopyFilesBuildPhase)
  copy_phase.name = 'Embed Foundation Extensions'
  copy_phase.symbol_dst_subfolder_spec = :plug_ins
  runner.build_phases << copy_phase
end

build_file = copy_phase.add_file_reference(extension_target.product_reference)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# Target dependency
runner.add_dependency(extension_target)

# Build settings
entitlements = 'VoclioWidgetExtension.entitlements'
runner_entitlements = 'Runner/Runner.entitlements'

runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = runner_entitlements
end

extension_target.build_configurations.each do |config|
  config.build_settings.merge!(
    'CODE_SIGN_ENTITLEMENTS' => entitlements,
    'INFOPLIST_FILE' => 'VoclioWidget/Info.plist',
    'IPHONEOS_DEPLOYMENT_TARGET' => '14.0',
    'LD_RUNPATH_SEARCH_PATHS' => [
      '$(inherited)',
      '@executable_path/Frameworks',
      '@executable_path/../../Frameworks'
    ],
    'PRODUCT_BUNDLE_IDENTIFIER' => 'com.example.voclioApp.VoclioWidget',
    'PRODUCT_NAME' => '$(TARGET_NAME)',
    'SKIP_INSTALL' => 'YES',
    'SWIFT_VERSION' => '5.0',
    'APPLICATION_EXTENSION_API_ONLY' => 'YES',
    'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME' => 'AccentColor',
    'ASSETCATALOG_COMPILER_WIDGET_BACKGROUND_COLOR_NAME' => 'WidgetBackground',
    'CURRENT_PROJECT_VERSION' => '$(FLUTTER_BUILD_NUMBER)',
    'MARKETING_VERSION' => '$(FLUTTER_BUILD_NAME)',
    'TARGETED_DEVICE_FAMILY' => '1,2'
  )
end

project.save
puts "Added #{extension_name} target successfully"
