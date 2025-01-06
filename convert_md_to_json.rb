require 'json'
require 'yaml'
require 'fileutils'

# Directory containing markdown files
docs_dir = '/Users/ripley/Sites/leksiko/_docs'

# Get all markdown files in the directory
md_files = Dir.glob(File.join(docs_dir, '*.md'))

# Array to hold all JSON data
all_json_data = []

md_files.each do |file_path|
  # Read the markdown file
  content = File.read(file_path)

  # Split the content into front matter and body
  front_matter, body = content.split('---', 3)[1..2]

  # Parse the front matter as YAML
  metadata = YAML.load(front_matter)

  # Extract sections
  sections = {}
  current_section = nil
  body.each_line do |line|
    if line.start_with?('## ')
      current_section = line.strip[3..]
      sections[current_section] = ''
    elsif current_section
      sections[current_section] += line
    end
  end

  # Remove leading and trailing newlines from sections
  sections.each do |key, value|
    sections[key] = value.strip
  end

  # Extract 'Aliaj Lingvoj' section
  languages = {}
  if sections['Aliaj Lingvoj']
    sections['Aliaj Lingvoj'].strip.split("\n").each do |line|
      next unless line.start_with?('- ')
      lang, translation = line[2..].split(':').map(&:strip)
      languages[lang] = translation
    end
    sections.delete('Aliaj Lingvoj')
  end

  # Extract 'Referencoj' section
  references = []
  if sections['Referencoj']
    sections['Referencoj'].strip.split("\n").each do |line|
      next unless line.start_with?('* ')
      title, url = line[2..].split(' - ').map(&:strip)
      references << { title: title, url: url }
    end
    sections.delete('Referencoj')
  end

  # Prepare the JSON structure
  json_data = {
    metadata: metadata,
    sections: sections,
    languages: languages,
    references: references
  }

  # Add the JSON data to the array
  all_json_data << json_data

  puts "Processed #{file_path}"
end

# Write all JSON data to a single file
output_file_path = '/Users/ripley/Sites/leksiko/leksiko_md.json'
File.open(output_file_path, 'w') do |file|
  file.write(JSON.pretty_generate(all_json_data))
end

puts "All data saved to #{output_file_path}"
