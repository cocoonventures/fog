require 'fog/core/model'

module Fog
  module Compute
    class Google

      class Disk < Fog::Model

        identity :name

        attribute :kind, :aliases => 'kind'
        attribute :id, :aliases => 'id'
        attribute :creation_timestamp, :aliases => 'creationTimestamp'
        attribute :zone_name, :aliases => 'zone'
        attribute :status, :aliases => 'status'
        attribute :description, :aliases => 'description'
        attribute :size_gb, :aliases => 'sizeGb'
        attribute :self_link, :aliases => 'selfLink'
        attribute :image_name, :aliases => 'image'

        def save
          data = service.insert_disk(name, size_gb, zone_name, image_name).body
          data = service.get_disk(self.name, zone_name).body
          service.disks.merge_attributes(data)
        end

        def get_as_boot_disk(writable=true)
          mode = writable ? 'READ_WRITE' : 'READ_ONLY'
          return {
              'name' => name,
              'type' => 'PERSISTENT',
              'boot' => true,
              'source' => self_link,
              'mode' => mode
          }
        end

        def ready?
          data = service.get_disk(self.name, self.zone_name).body
          data['zone_name'] = self.zone_name
          self.merge_attributes(data)
          self.status == RUNNING_STATE
        end

        def reload
          requires :identity
          requires :zone_name

          return unless data = begin
            collection.get(identity, zone_name)
          rescue Excon::Errors::SocketError
            nil
          end

          new_attributes = data.attributes
          merge_attributes(new_attributes)
          self
        end

        RUNNING_STATE = "READY"

      end
    end
  end
end