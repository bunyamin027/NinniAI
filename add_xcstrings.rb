require 'xcodeproj'

project_path = 'NinniAI.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.first

# Check if file is already added
unless target.source_build_phase.files_references.any? { |ref| ref.path == 'Localizable.xcstrings' }
  # Get or create NinniAI group
  main_group = project.main_group.groups.find { |g| g.path == 'NinniAI' } || project.main_group
  
  # Add file reference
  file_ref = main_group.new_reference('Localizable.xcstrings')
  
  # Add to build phase
  target.resources_build_phase.add_file_reference(file_ref, true)
  
  project.save
  puts "Successfully added Localizable.xcstrings to Xcode project."
else
  puts "Localizable.xcstrings already exists in Xcode project."
end
