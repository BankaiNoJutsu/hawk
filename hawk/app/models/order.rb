# Copyright (c) 2009-2015 Tim Serong <tserong@suse.com>
# See COPYING for license.

class Order < Constraint
  attribute :id, String
  attribute :score, String
  attribute :symmetrical, Boolean
  attribute :resources, Array[Hash]

  validates :id,
    presence: { message: _("Constraint ID is required") },
    format: { with: /\A[a-zA-Z0-9_-]+\z/, message: _("Invalid Constraint ID") }

  validates :score,
    presence: { message: _("Score is required") }

  validate do |record|
    record.score.strip!

    unless [
      "mandatory",
      "advisory",
      "inf",
      "-inf",
      "infinity",
      "-infinity"
    ].include? record.score.downcase
      unless record.score.match(/^-?[0-9]+$/)
        errors.add :score, _("Invalid score value")
      end
    end

    if record.resources.length < 2
      errors.add :base, _("Constraint must consist of at least two separate resources")
    end
  end

  def resources
    @resources ||= []
  end

  def resources=(value)
    @resources = value
  end

  class << self
    def all
      super.select do |record|
        record.is_a? self
      end
    end
  end

  protected

  def shell_syntax
    [].tap do |cmd|
      cmd.push "order #{id} #{score}:"

      resources.each do |set|
        cmd.push "(" unless set[:sequential] == "true" && set[:sequential]

        set[:resources].each do |resource|
          if set[:action].empty?
            cmd.push resource
          else
            cmd.push [
              resource,
              set[:action]
            ].join(":")
          end
        end

        cmd.push ")" unless set[:sequential] == "true" && set[:sequential]
      end

      unless symmetrical
        cmd.push "symmetrical=false"
      end
    end.join(" ")
  end

  class << self
    def instantiate(xml)
      record = allocate
      record.score = xml.attributes["score"] || nil

      record.symmetrical = Util.unstring(
        xml.attributes["symmetrical"],
        true
      )

      record.resources = [].tap do |resources|
        if xml.attributes["first"]
          resources.push(
            sequential: true,
            action: xml.attributes["first-action"] || nil,
            resources: [
              xml.attributes["first"]
            ]
          )

          resources.push(
            sequential: true,
            action: xml.attributes["then-action"] || nil,
            resources: [
              xml.attributes["then"]
            ]
          )
        else
          xml.elements.each do |resource|
            set = {
              sequential: Util.unstring(resource.attributes["sequential"], true),
              action: resource.attributes["action"] || nil,
              resources: []
            }

            resource.elements.each do |el|
              set[:resources].push(
                el.attributes["id"]
              )
            end

            resources.push set
          end
        end
      end

      record
    end

    def cib_type_write
      :rsc_order
    end
  end
end
