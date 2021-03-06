require 'csv'
require 'time'
require 'pry'

require_relative 'user'
require_relative 'trip'
require_relative 'driver'

module RideShare
  class TripDispatcher
    attr_reader :drivers, :passengers, :trips

    def initialize(user_file = 'support/users.csv',
      trip_file = 'support/trips.csv',
      driver_file = 'support/drivers.csv')
      @passengers = load_users(user_file)
      @drivers = load_drivers(driver_file)
      @trips = load_trips(trip_file)
    end

    def load_users(filename)
      users = []

      CSV.read(filename, headers: true).each do |line|
        input_data = {}
        input_data[:id] = line[0].to_i
        input_data[:name] = line[1]
        input_data[:phone] = line[2]

        users << User.new(input_data)
      end

      return users
    end


    def load_trips(filename)
      trips = []
      trip_data = CSV.open(filename, 'r', headers: true,
        header_converters: :symbol)

        trip_data.each do |raw_trip|
          passenger = find_passenger(raw_trip[:passenger_id].to_i)
          driver = find_driver(raw_trip[:driver_id].to_i)

          parsed_trip = {
            id: raw_trip[:id].to_i,
            passenger: passenger,
            #2018-06-07 04:18:47 -0700
            start_time: Time.parse(raw_trip[:start_time]),
            #,2018-06-07 04:19:25 -0700
            end_time: Time.parse(raw_trip[:end_time]),
            cost: raw_trip[:cost].to_f,
            rating: raw_trip[:rating].to_i,
            driver: driver
          }

          create_trip(parsed_trip, driver, passenger, trips)
        end

        return trips
      end


      def load_drivers(filename)
        drivers = []
        driver_data = CSV.open(filename, 'r', headers: true, header_converters: :symbol)

        driver_data.each do |raw_driver|
          user_with_same_id = find_passenger(raw_driver[0].to_i)

          parsed_driver = {
            id: raw_driver[0].to_i,
            vin: raw_driver[1],
            name: user_with_same_id.name,
            phone_number: user_with_same_id.phone_number,
            status: raw_driver[2].to_sym
          }

          driver = Driver.new(parsed_driver)
          drivers << driver
        end

        return drivers
      end


      def find_passenger(id)
        check_id(id)
        return @passengers.find { |passenger| passenger.id == id }
      end


      def find_driver(id)
        check_id(id)
        return @drivers.find { |driver| driver.id == id }
      end

      def create_trip(trip_data, driver, passenger, trip_list)
        trip = Trip.new(trip_data)
        passenger.add_trip(trip)
        driver.add_driven_trip(trip)
        trip_list << trip
        return trip
      end


      def request_trip(user_id)
        available_drivers = @drivers.select { |driver| driver.status == :AVAILABLE}

        passenger = find_passenger(user_id)
        driver = available_drivers.first

        trip_data = {
          start_time: Time.now,
          end_time: nil,
          passenger: passenger,
          driver: driver,
          cost: nil,
          rating: nil
        }

        trip_data[:driver].status = :UNAVAILABLE
        new_trip = create_trip(trip_data, driver, passenger, @trips)

        return new_trip
      end

      def inspect
        return "#<#{self.class.name}:0x#{self.object_id.to_s(16)} \
        #{trips.count} trips, \
        #{drivers.count} drivers, \
        #{passengers.count} passengers>"
      end

      private

      def check_id(id)
        raise ArgumentError, "ID cannot be blank or less than zero. (got #{id})" if id.nil? || id <= 0
      end
    end
  end
