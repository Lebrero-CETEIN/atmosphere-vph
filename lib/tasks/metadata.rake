
task purge_metadata_registry: :environment do

  puts "PURGING METADATA REGISTRY. Env = #{Rails.env}."

  global_ids = MetadataRepositoryClient.instance.get_active_global_ids
  if global_ids.nil?
    puts 'Problem with obtaining current MDS global ids list. Exiting'
    exit 1
  end

  global_ids.each do |metadata_global_id|
    MetadataRepositoryClient.instance.purge_metadata_key(metadata_global_id)
    puts metadata_global_id
  end
end


# This removes from MDS all AtomicService elements which are no longer present in AIR
# or were set as private (visible_to == owner).
# It updates every published AT.

task sync_metadata: :environment do

  puts "SYNCING METADATA. Env = #{Rails.env}."

  global_ids = MetadataRepositoryClient.instance.get_active_global_ids
  if global_ids.nil?
    puts 'Problem with obtaining current MDS global ids list. Exiting'
    exit 1
  end

  global_ids.each do |metadata_global_id|
    if Atmosphere::ApplianceType.where(metadata_global_id: metadata_global_id).present? and Atmosphere::ApplianceType.where(metadata_global_id: metadata_global_id).first.publishable?
      # MetadataRepositoryClient.instance.update_appliance_type Atmosphere::ApplianceType.where(metadata_global_id: metadata_global_id).first
      puts "U: [#{metadata_global_id}]"
    else
      # MetadataRepositoryClient.instance.purge_metadata_key(metadata_global_id)
      puts "D: [#{metadata_global_id}]"
    end
  end

  Atmosphere::ApplianceType.all.select{|at| !global_ids.include?(at.metadata_global_id)}.each do |at|
    if at.publishable?
      #at.update_column(:metadata_global_id, nil)  # In case AIR still thinks it is published all right, we need to fool it
      #mgid = MetadataRepositoryClient.instance.publish_appliance_type at
      #at.update_column(:metadata_global_id, mgid) if mgid
      puts "A: [#{at.name}]"
    elsif at.metadata_global_id
      #at.update_column(:metadata_global_id, nil)
      puts "C: [#{at.name}]"
    end
  end
end


task clean_metadata_registry: :environment do

  puts "CLEANING METADATA REGISTRY. Env = #{Rails.env}."

  if Rails.env.development?
    puts 'NOT ALLOWED ON DEVELOPMENT. Exiting.'
    exit 1
  end

  if Rails.env.production?
    global_ids = MetadataRepositoryClient.instance.get_active_global_ids
    if global_ids.nil?
      puts 'Problem with obtaining current MDS global ids list. Exiting'
      exit 1
    end

    puts global_ids
    Atmosphere::ApplianceType.transaction do
      Atmosphere::ApplianceType.where(visible_to: ['all','developer']).all.each do |at|
        if at.metadata_global_id
          puts "Removing Atmosphere::ApplianceType #{at.name}."
          if MetadataRepositoryClient.instance.delete_metadata(at)
            at.update_column(:metadata_global_id, nil)
          end
        end
      end
    end
  end
end


task populate_metadata_registry: :environment do

  puts "POPULATING METADATA REGISTRY. Env = #{Rails.env}."

  if Rails.env.development?
    puts 'NOT ALLOWED ON DEVELOPMENT. Exiting.'
    exit 1
  end

  if Rails.env.production?

    global_ids = MetadataRepositoryClient.instance.get_active_global_ids
    if global_ids.nil?
      puts 'Problem with obtaining current MDS global ids list. Exiting'
      exit 1
    end

    Atmosphere::ApplianceType.transaction do
      Atmosphere::ApplianceType.where(visible_to: ['all','developer']).all.each do |at|
        if at.metadata_global_id and global_ids.include?(at.metadata_global_id)
          puts "Updating Atmosphere::ApplianceType #{at.name}."
          MetadataRepositoryClient.instance.update_appliance_type at
        else
          puts "Publishing or re-publishing Atmosphere::ApplianceType #{at.name}."
          mgid = MetadataRepositoryClient.instance.publish_appliance_type at
          at.update_column(:metadata_global_id, mgid) if mgid
        end
      end

    end
  end
end
