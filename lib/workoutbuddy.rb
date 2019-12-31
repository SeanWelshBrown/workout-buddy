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
  end

  # GENERAL METHODS #

  def greet
    puts "Welcome to WorkoutBuddy, your source for quality exercise tips and your very own personal workout tracker!"
  end

  def exit
    input = PROMPT.ask('Are you sure you want to exit? (yes/no)', convert: :string, required: true) do |q|
      q.modify :down
    end
    if input == "yes"
      puts "So long for now!"
      abort
    elsif input == "no"
      method = caller_locations.last.label
      method
    elsif !input.include?("yes" || "no")
      puts "Please enter 'yes' or 'no'"
      exit
    end
  end

  def exit_check(input)
    if input == "exit"
      exit
    end
  end

  # LOGIN METHODS #

  def find_user(input)
    User.find_by(username: input)
  end

  def log_into_account
    input = PROMPT.ask("Please enter your Username, or 'create account' to create a new account. You may also enter 'exit' to exit the program.", convert: :string, required: true)
    if input == "create account"
      create_account
    end
    exit_check(input)

    user_check = find_user(input)
    if user_check
      @@current_user = user_check
      puts "Successfully logged in. Nice to see you again, #{@@current_user.first_name}!"
    elsif !user_check
      puts "No User Account found with that Username. Please try again."
      log_into_account
    end
  end

  def create_account
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

    user_check = find_user(input1)

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

  def login
    input = PROMPT.select("Please log in to your existing account, or create a new account if you are a new user. (It's easy, we promise!)", ["Log in", "Create an Account", "Exit Application"])
    if input == "Log in"
      log_into_account
    elsif input == "Create an Account"
      puts "Thank you for choosing to create an account!"
      create_account
    elsif input == "Exit Application"
      exit
    end
  end

  # MAIN MENU METHODS #

  def main_menu
    
  end

end