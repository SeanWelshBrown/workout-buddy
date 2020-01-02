require "tty-prompt"
require "pry"

PROMPT = TTY::Prompt.new

class WorkoutBuddy

  @@current_user = nil
  attr_accessor :current_user

  # RUNNER METHOD #

  def run 
    greet
    login
    sleep 2
    main_menu
  end

  # GENERAL METHODS #

  def greet
    system 'clear'
    puts "Welcome to WorkoutBuddy, your source for quality exercise tips and your very own personal workout tracker!"
    puts "\n"
  end

  def exit_app
    input = PROMPT.ask('Are you sure you want to exit? (y/n)', convert: :string, required: true) do |q|
      q.modify :down
    end
    if input == "yes" || input == "y"
      puts "So long for now!"
      abort
    elsif input == "no" || input == "n"
      go_to_previous_menu
    elsif !input.include?("yes" || "no")
      puts "Please enter 'yes' or 'no'"
      exit_app
    end
  end

  def exit_check(input)
    if input == "exit"
      exit_app
    end
  end

  def find_user_by_username(input)
    User.find_by(username: input)
  end

  def go_to_previous_menu
    previous_method = caller[-3].split("`").pop.gsub("'", "")
    previous_method.to_sym
    send(previous_method)
  end

  # LOGIN METHODS #

  def login
    input = PROMPT.select("Please log in to your existing account, or create a new account if you are a new user. (It's easy, we promise!)", ["Log in", "Create an Account", "Exit Application"])

    if input == "Log in"
      log_into_account
    elsif input == "Create an Account"
      puts "Thank you for choosing to create an account!"
      create_account
    elsif input == "Exit Application"
      exit_app
    end
  end

  def log_into_account
    system 'clear'
    input = PROMPT.ask("Please enter your Username, or 'create account' to create a new account. You may also enter 'exit' to exit the program.", convert: :string, required: true)
    if input == "create account"
      create_account
    end
    exit_check(input)

    user_check = find_user_by_username(input)
    if user_check
      @@current_user = user_check
      puts "Successfully logged in. Nice to see you again, #{@@current_user.first_name}!"
    elsif !user_check
      puts "No User Account found with that Username. Please try again."
      log_into_account
    end
  end

  def create_account
    system 'clear'

    username = nil
    first_name = nil
    last_name = nil
    age = nil

    input1 = PROMPT.ask("Please enter a Username. You may use only upper and lower case letters, as well as numbers. You may also enter 'exit' to exit the program.", convert: :string, required: true)

    if input1.index( /[^[:alnum:]]/ ) || input1.include?(" ")
      puts "Username contains invalid characters."
      create_account
    end
    exit_check(input1)

    user_check = find_user_by_username(input1)

    if user_check
      puts "This Username already exists."
      create_account
    elsif !user_check
      username = input1
      first_name = PROMPT.ask("Please enter your first name:", default: nil, convert: :string, required: true)
      exit_check(first_name)
      last_name = PROMPT.ask("Please enter your last name:", default: nil, convert: :string, required: true)
      exit_check(last_name)
      age = PROMPT.ask("Please enter your current age:", default: nil, convert: :int, required: true)
      exit_check(age)
      
      sleep 1.5

      @@current_user = User.create(username: username, first_name: first_name, last_name: last_name, age: age)
      puts "Account successfully created! You are now logged in as #{username}."
    end

  end

  # MAIN MENU #

  def main_menu
    system 'clear'

    puts "MAIN MENU"
    input = PROMPT.select("Please select an option to navigate:", ["View Exercises", "View Your Saved Exercises", "Edit Account Information", "Log Out", "Exit Application"])

    if input == "View Exercises"
      view_exercises
    elsif input == "View Your Saved Exercises"

    elsif input == "Edit Account Information"

    elsif input == "Log Out"
      @@current_user = nil
      system 'clear'
      login
    elsif input == "Exit Application"
      exit_app
    end
  end

  # 'VIEW EXERCISES' METHODS #

    # GENERAL EXERCISE METHODS #

    def find_exercise_type(input)
      Exercise.where("type = '#{input}'")
    end
  
    def find_exercise_body_part(input)
      Exercise.where(["type = ? and body_part = ?", "Strength", "#{input}"])
    end
  
    def display_exercise_info(exercise_name, previous_menu)
      exercise = Exercise.find_by(name: exercise_name)
      puts "Name: #{exercise.name}"
      puts "\n"
      puts "Muscle Group: #{exercise.muscle_group}"
      puts "\n"
      puts "Description"
      puts exercise.description
      puts "\n"

      sleep 1.5

      input = PROMPT.select("What would you like to do?", ["Add this exercise to my workout list", "Go back to previous menu"])

      if input == "Add this exercise to my workout list"

      elsif input == "Go back to previous menu"
        go_to_previous_menu
      end
    end

    # EXERCISE MENU #

  def view_exercises
    input = PROMPT.select("Would you like to learn about Strength Training or Cardio exercises?", ["Strength Training", "Cardio", "Go back to previous menu"])

    if input == "Strength Training"

    elsif input == "Cardio"

    elsif input == "Go back to previous menu"
      go_to_previous_menu
    end
  end

    # STRENGTH MENU #

  def strength_training
    input = PROMPT.select("What part of the body would you like to focus on?", ["Arms", "Legs", "Core"])

    if input == "Arms"
      arms
    elsif input == "Legs"
      legs
    elsif input == "Core"
      core
    end
  end

  def arms

  end

  def legs
    
  end

  def core 

  end

end