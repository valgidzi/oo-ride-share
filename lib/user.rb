module RideShare
  class User
    attr_reader :id, :name, :phone_number, :trips

    def initialize(input)
      if input[:id].nil? || input[:id] <= 0
        raise ArgumentError, 'ID cannot be blank or less than zero.'
      end

      @id = input[:id]
      @name = input[:name]
      @phone_number = input[:phone]
      @trips = input[:trips].nil? ? [] : input[:trips]
    end

    def add_trip(trip)
      @trips << trip
    end

    def net_expenditures
      # all_trips = @user.trips
      array = []
      @trips.each do |trip|
        array << trip.cost
      end
      return array.sum

    end

    def total_time_spent
      array = []
      @trips.each do |trip|
        array << trip.calculate_duration
      end
      return array.sum
    end

  end
end
