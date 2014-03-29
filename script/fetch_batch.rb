require './lib/team_fitness.rb'

repo_sets = [
  # [repo_name, sampling_frequency]
  ['rails/rails', 10],
]
export_folder = 'export/'

repo_sets.each do |repo, freq|
  puts "Start #{repo}"
  tf = TeamFitness.new(repo)

  tf.fetch(freq)
  puts "Fetched comments of #{repo}"

  export_path = export_folder + repo.gsub('/', '.')

  tf.export_csv_to(export_path)
  puts "Exported to #{export_path}"
end

