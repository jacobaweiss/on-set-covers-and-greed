require 'csv'

class ProficiencyFinder
  Workout = Struct.new(:score, :categories)

  def initialize(workouts_csv, categories)
    @categories = categories
    @members = {}
    create_member_workouts_hash(workouts_csv)
  end

  def find_least_proficient
    solution = least_proficient_member_and_score
    if solution.length > 0
      puts solution.join(', ')
    else
      puts "No solution"
    end
  end

  private

  def create_member_workouts_hash(csv_file)
    CSV.foreach(csv_file) do |row|
      row = row.map{ |i| i.gsub(/\s+/, '') }
      member = row[0].to_sym
      workout = Workout.new(row[1].to_f, row[2..-1])

      if @members.include?(member)
        @members[member].push(workout)
      else
        @members[member] = [workout]
      end
    end
  end

  def least_proficient_member_and_score
    least = []
    @members.each do |name, v|
      puts "Selecting minimum workout score combinations for #{name}"
      min_score_combo = get_min_score_combo(v)
      puts()
      if !min_score_combo.nil?
        least = [name, min_score_combo.to_i] if least[1].nil? || (min_score_combo < least[1])
      end
    end
    return least
  end

  def get_min_score_combo(workouts)
    desired = @categories
    best_choices = []
    while desired.any?
      best = min(workouts, desired)
      return nil unless best
      puts "Choosing #{best.categories.join(' & ')} for #{best.score}"
      best_choices = best_choices | [best]
      desired = desired - best.categories
    end
    return best_choices.map(&:score).reduce(&:+)
  end

  def min(workouts, desired)
    min = 1.0/0
    min_workout = nil
    workouts.each do |workout|
      intersection = workout.categories & desired
      value =  workout.score / intersection.length
      if value < min
        min = value
        min_workout = workout
      end
    end
    return min_workout
  end
end
