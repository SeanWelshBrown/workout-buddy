require "tty-prompt"
require "tty-table"
require "pry"

PROMPT = TTY::Prompt.new

class WorkoutBuddy

  @@current_user = nil
  attr_accessor :current_user

#*** RUNNER METHOD ***#

  def run 
    login
    sleep 2
    main_menu
  end

#~~~ GENERAL METHODS ~~~#

  def logo 
    file = File.open("lib/ascii/logo.txt")
    logo = file.read
    puts logo 
  end

  def exit_app(current_menu)
    system 'clear'

    input = PROMPT.select('Are you sure you want to exit?', ["Yes", "No"], cycle: true)
    if input == "Yes"
      puts "So long for now!"
      abort
    elsif input == "No"
      current_menu.to_sym
      send(current_menu)
    end
  end

  def back_check(input, current_menu)
    if input == "go back"
      current_menu.to_sym
      send(current_menu)
    end
  end

  def find_user_by_username(input)
    User.find_by(username: input)
  end

  # def go_to_previous_menu(caller_num) # MAKE BLOG POST ABOUT THIS #
  #   previous_method = caller[caller_num].split("`").pop.gsub("'", "")
  #   previous_method.to_sym
  #   send(previous_method)
  # end

#~~~ LOGIN METHODS ~~~#

  def login
    system 'clear'

    puts logo

    puts "Welcome to WorkoutBuddy, your source for quality exercise tips and your very own personal exercise tracker!"
    puts "\n"

    input = PROMPT.select("Please log in to your existing account, or create a new account if you are a new user. (It's easy, we promise!)", ["Log in", "Create an Account", "\u{1f6ab} Exit Application"], cycle: true)

    if input == "Log in"
      log_into_account
    elsif input == "Create an Account"
      puts "Thank you for choosing to create an account!"
      create_account
    elsif input == "\u{1f6ab} Exit Application"
      exit_app("login")
    end
  end

  def log_into_account
    system 'clear'
    input = PROMPT.ask("Please enter your Username, or 'create account' to create a new account. You may also enter 'go back' to return to the previous menu.", convert: :string, required: true)
    if input == "create account"
      create_account
    end
    back_check(input, "login")

    user_check = find_user_by_username(input)
    if user_check
      system 'clear'
      @@current_user = user_check
      puts "Successfully logged in. Nice to see you again, #{@@current_user.first_name}!"
    elsif !user_check
      puts "No User Account found with that Username. Please try again."
      sleep 1.5
      log_into_account
    end
  end

  def create_account
    system 'clear'

    username = nil
    first_name = nil
    last_name = nil
    age = nil

    input1 = PROMPT.ask("Please enter a Username. You may use only upper and lower case letters, as well as numbers. You may also enter 'go back' to return to the previous menu:", convert: :string, required: true)
    
    back_check(input1, "login")

    if input1.index( /[^[:alnum:]]/ ) || input1.include?(" ")
      puts "Username contains invalid characters."
      create_account
    end

    user_check = find_user_by_username(input1)

    if user_check
      puts "This Username already exists."
      create_account
    elsif !user_check
      username = input1
      first_name = PROMPT.ask("Please enter your first name. You may also enter 'go back' to return to the previous menu:", default: nil, convert: :string, required: true)
      back_check(first_name, "login")
      last_name = PROMPT.ask("Please enter your last name. You may also enter 'go back' to return to the previous menu:", default: nil, convert: :string, required: true)
      back_check(last_name, "login")
      age = PROMPT.ask("Please enter your current age. You may also enter 'go back' to return to the previous menu:", default: nil, convert: :int, required: true)
      back_check(age, "login")
      
      sleep 1.5

      @@current_user = User.create(username: username, first_name: first_name, last_name: last_name, age: age)
      puts "Account successfully created! You are now logged in as #{username}."
      return
    end

  end

#~~~ MAIN MENU ~~~#

  def main_menu
    system 'clear'

    puts "*--- MAIN MENU ---*"
    puts "\n"

    input = PROMPT.select("Please select an option to navigate, #{@@current_user.first_name}:", ["View Exercises", "View/Edit Your Saved Exercises", "Edit Account Information", "\u{1f6b7} Log Out (#{@@current_user.username})", "\u{1f6ab} Exit Application"], cycle: true)

    if input == "View Exercises"
      view_exercises
    elsif input == "View/Edit Your Saved Exercises"
      view_edit_saved_exercises
    elsif input == "Edit Account Information"
      account_info
    elsif input == "\u{1f6b7} Log Out (#{@@current_user.username})"
      @@current_user = nil
      system 'clear'
      run
    elsif input == "\u{1f6ab} Exit Application"
      exit_app("main_menu")
    end
  end

#~~~ 'VIEW EXERCISES' ~~~#

    #--- GENERAL EXERCISE METHODS ---#

  def find_exercise_by_type(input)
    Exercise.where("exercise_type = '#{input}'")
  end

  def find_exercise_by_body_part(input)
    Exercise.where(["exercise_type = ? and body_part = ?", "Strength", "#{input}"])
  end

  def user_exercise_checker(user, exercise)
    UserExercise.find_by(user_id: user, exercise_id: exercise)
  end

  def display_exercise_info(exercise_name, current_menu)
    system 'clear'

    exercise = Exercise.find_by(name: exercise_name)
    puts "Name: #{exercise.name}"
    puts "\n"
    puts "Body Part: #{exercise.body_part}"
    puts "\n"
    puts "Muscle Group: #{exercise.muscle_group}"
    puts "\n"
    puts "Description:"
    puts "\n"
    puts exercise.description
    puts "\n"

    sleep 1

    input = PROMPT.select("What would you like to do?", ["Add this exercise to my workout list", "\u{2b05}  Go back to previous menu"], cycle: true)
    
    if input == "Add this exercise to my workout list"
      if user_exercise_checker(@@current_user.id, exercise.id)
        system 'clear'
        input = PROMPT.select("This exercise is already in your workout list.", ["\u{2b05}  Go back to previous menu"])
        if input
          menu = current_menu.to_sym
          send(menu)
        end
      elsif !user_exercise_checker(@@current_user.id, exercise.id)
        UserExercise.create(user_id: @@current_user.id, exercise_id: exercise.id)
        input = PROMPT.select("Exercise successfully saved!", ["\u{2b05}  Go back to previous menu"])
        if input
          menu = current_menu.to_sym
          send(menu)
        end
      end
    elsif input == "\u{2b05}  Go back to previous menu"
      menu = current_menu.to_sym
      send(menu)
    end
  end

  def display_or_remove_exercise(exercise_name, current_menu)
    system 'clear'

    exercise = Exercise.find_by(name: exercise_name)
    puts "Name: #{exercise.name}"
    puts "\n"
    puts "Body Part: #{exercise.body_part}"
    puts "\n"
    puts "Muscle Group: #{exercise.muscle_group}"
    puts "\n"
    puts "Description:"
    puts "\n"
    puts exercise.description
    puts "\n"

    sleep 1

    input = PROMPT.select("What would you like to do?", ["\u{1f6ab}  Remove this exercise from my workout list", "\u{2b05}  Go back to previous menu"], cycle: true)
    
    if input == "\u{1f6ab}  Remove this exercise from my workout list"
      system 'clear'
      input2 = PROMPT.select("Are you sure you want to remove this exercise from your list?", ["Yes", "No"])
      if input2 == "Yes"
        sleep 1
        remove_exercise(exercise)
        input3 = PROMPT.select("Exercise successfully removed.", ["\u{2b05}  Go back to previous menu"])
        if input3
          menu = current_menu.to_sym
          send(menu)
        end
      elsif input2 == "No"
        menu = current_menu.to_sym
        send(menu)
      end
    elsif input == "\u{2b05}  Go back to previous menu"
      menu = current_menu.to_sym
      send(menu)
    end
  end

  def remove_exercise(exercise)
    UserExercise.find_by(user_id: @@current_user.id, exercise_id: exercise.id).destroy
  end

    #--- EXERCISE MENU ---#

  def view_exercises
    system 'clear'

    puts "*--- VIEW EXERCISES ---*"
    puts "\n"

    input = PROMPT.select("Would you like to learn about Strength Training or Cardio exercises?", ["\u{1F3CB} Strength Training", "\u{1F3C3} Cardio", "\u{2b05}  Go back to previous menu"], cycle: true)

    if input == "\u{1F3CB} Strength Training"
      strength_training
    elsif input == "\u{1F3C3} Cardio"
      cardio
    elsif input == "\u{2b05}  Go back to previous menu"
      main_menu
    end
  end

    #--- STRENGTH MENU ---#

  def strength_training
    system 'clear'

    puts "*--- STRENGTH TRAINING ---*"
    puts "\n"

    input = PROMPT.select("What part of the body would you like to focus on?", ["\u{1F4AA} Upper Body", "\u{1F9B5} Legs", "\u{1F455} Core", "\u{2b05}  Go back to previous menu"], cycle: true)

    if input == "\u{1F4AA} Upper Body"
      upper_body
    elsif input == "\u{1F9B5} Legs"
      legs
    elsif input == "\u{1F455} Core"
      core
    elsif input == "\u{2b05}  Go back to previous menu"
      view_exercises
    end
  end

  def upper_body
    system 'clear'

    upper_body_exercises = []
    upper_body_exercises << find_exercise_by_body_part("Arms")
    upper_body_exercises << find_exercise_by_body_part("Chest")
    upper_body_exercises << find_exercise_by_body_part("Shoulders")
    flatten_exercises = upper_body_exercises.flatten

    exercise_names = flatten_exercises.collect { |exercise| exercise.name }

    puts "*--- UPPER BODY ---*"
    puts "\n"

    input = PROMPT.select("Select an exercise for more information:", exercise_names, "\u{2b05}  Go back to previous menu", cycle: true)

    if input == "\u{2b05}  Go back to previous menu"
      strength_training
    else display_exercise_info(input, "upper_body")
    end
  end

  def legs
    system 'clear'

    leg_exercises = []
    leg_exercises << find_exercise_by_body_part("Upper Legs")
    leg_exercises << find_exercise_by_body_part("Lower Legs")
    flatten_exercises = leg_exercises.flatten

    exercise_names = flatten_exercises.collect { |exercise| exercise.name }

    puts "*--- LEGS ---*"
    puts "\n"

    input = PROMPT.select("Select an exercise for more information:", exercise_names, "\u{2b05}  Go back to previous menu", cycle: true)

    if input == "\u{2b05}  Go back to previous menu"
      strength_training
    else display_exercise_info(input, "legs")
    end
  end

  def core 
    system 'clear'

    core_exercises = []
    core_exercises << find_exercise_by_body_part("Abs")
    flatten_exercises = core_exercises.flatten

    exercise_names = flatten_exercises.collect { |exercise| exercise.name }

    puts "*--- CORE ---*"
    puts "\n"

    input = PROMPT.select("Select an exercise for more information:", exercise_names, "\u{2b05}  Go back to previous menu", cycle: true)

    if input == "\u{2b05}  Go back to previous menu"
      strength_training
    else display_exercise_info(input, "core")
    end
  end

    #--- CARDIO MENU ---#

  def cardio
    system 'clear'

    cardio_exercises = find_exercise_by_type("Cardio")

    exercise_names = cardio_exercises.collect { |exercise| exercise.name }

    puts "*-- CARDIO --*"
    puts "\n"

    input = PROMPT.select("Select an exercise for more information:", exercise_names, "\u{2b05}  Go back to previous menu", cycle: true)

    if input == "\u{2b05}  Go back to previous menu"
      view_exercises
    else display_exercise_info(input, "cardio")
    end
  end

#~~~ VIEW/EDIT SAVED EXERCISES ~~~*

  def view_edit_saved_exercises
    system 'clear'

    puts "*--- SAVED EXERCISES (YOUR WORKOUT) ---*"
    puts "\n"

    puts "Here is your current list of saved exercises, #{@@current_user.first_name}."
    puts "\n"
    puts "You may select an exercise to view its details again, or delete it from your list."
    puts "\n"

    saved_exercises = @@current_user.exercises
    saved_exercises.reload
    saved_exercise_names = saved_exercises.collect {|exercise| exercise.name}

    input = PROMPT.select("Select an exercise:", saved_exercise_names, "\u{1f6ab}  Delete entire list", "\u{2b05}  Go back to previous menu", cycle: true)
    if input == "\u{1f6ab}  Delete entire list"
      system 'clear'
      input2 = PROMPT.select("Are you sure you want to delete your entire workout list?", ["Yes", "No"])
      if input2 == "Yes"
        delete_list
      elsif input2 == "No"
        view_edit_saved_exercises
      end
    elsif input == "\u{2b05}  Go back to previous menu"
      main_menu
    else display_or_remove_exercise(input, "view_edit_saved_exercises")
    end
  end

    #--- DELETE WORKOUT LIST METHOD ---#

  def delete_list
    sleep 1
    UserExercise.where(user_id: @@current_user.id).destroy_all
    input = PROMPT.select("List successfully deleted.", ["\u{2b05}  Go back to previous menu"])
    if input
      view_edit_saved_exercises
    end
  end

#~~~ USER ACCOUNT INFORMATION ~~~#

  def account_info
    system 'clear'
    table = TTY::Table.new [['Username:', @@current_user.username], ['First Name:', @@current_user.first_name], ['Last Name:', @@current_user.last_name], ['Age', @@current_user.age]]

    # table = TTY::Table[['a1', 'a2'], ['b1', 'b2']]

    puts "*--- ACCOUNT INFO ---*"
    puts "\n"
    puts "CURRENT INFORMATION"
    puts "\n"
    puts table.render :unicode

    puts "\n"

    input = PROMPT.select("Would you like to change any of your account information?", ["Username", "First Name", "Last Name", "Age", "\u{1f6ab}  Delete account", "\u{2b05}  Go back to previous menu"], cycle: true)

    if input == "Username"
      change_username
    elsif input == "First Name"
      change_first_name
    elsif input == "Last Name"
      change_last_name
    elsif input == "Age"
      change_age
    elsif input == "\u{1f6ab}  Delete account"
      system 'clear'
      input2 = PROMPT.select("Are you sure you want to delete your account? This is a permanent action, there will be no recovery of data possible after confirmation.", ["Yes", "No"])
      if input2 == "Yes"
        delete_account
      elsif input2 == "No"
        account_info
      end
    elsif input == "\u{2b05}  Go back to previous menu"
      main_menu
    end
  end

    #--- ACCOUNT METHODS ---*

  def change_username
    system 'clear'

    input = PROMPT.ask("Please enter a new Username. You may use only upper and lower case letters, as well as numbers. You may also enter 'go back' to return to the previous menu.", convert: :string, required: true)

    back_check(input, "account_info")

    if input.index( /[^[:alnum:]]/ ) || input.include?(" ")
      puts "Username contains invalid characters, please try again."
      sleep 1.5
      change_username
    end

    user_check = find_user_by_username(input)

    if user_check
      puts "This Username already exists. Please try again."
      sleep 1.5
      change_username
    elsif !user_check 
      @@current_user.username = input
      @@current_user.save
      sleep 1.5
      input2 = PROMPT.select("Username successfully changed!", "\u{2b05}  Go back to previous menu")
      if input2
        account_info
      end
    end
  end

  def change_first_name
    system 'clear'

    input = PROMPT.ask("Please enter a new preferred First Name. You may also enter 'go back' to return to the previous menu:", convert: :string, required: true)

    back_check(input, "account_info")

    sleep 1.5
    @@current_user.first_name = input
    @@current_user.save

    input2 = PROMPT.select("First Name successfully changed. Hello #{@@current_user.first_name}!", "\u{2b05}  Go back to previous menu")
    if input2
      account_info
    end
  end

  def change_last_name
    system 'clear'

    input = PROMPT.ask("Please enter a new Last Name. You may also enter 'go back' to return to the previous menu:", convert: :string, required: true)

    back_check(input, "account_info")

    sleep 1.5
    @@current_user.last_name = input
    @@current_user.save

    input2 = PROMPT.select("Last Name successfully changed. #{@@current_user.first_name} #{@@current_user.last_name} it is!", "\u{2b05}  Go back to previous menu")
    if input2
      account_info
    end
  end

  def change_age
    system 'clear'

    input = PROMPT.ask("Please update your age. You may also enter 'go back' to return to the previous menu:", convert: :string, required: true)

    back_check(input, "account_info")

    input.to_int

    sleep 1.5
    @@current_user.age = input
    @@current_user.save

    input2 = PROMPT.select("Age successfully updated. #{@@current_user.age} looks good on you!", "\u{2b05}  Go back to previous menu")
    if input2
      account_info
    end
  end

  def delete_account
    sleep 1
    User.find_by(id: @@current_user.id).destroy
    input = PROMPT.select("Account successfully deleted, we're sorry to see you go.", ["\u{2b05}  Return to Login menu"])
    if input
      login
    end
  end

end
