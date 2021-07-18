# README
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop/rubocop) [![Ruby Style Guide](https://img.shields.io/badge/code_style-community-brightgreen.svg)](https://rubystyle.guide)

* Figma: https://www.figma.com/file/kIjHU9EWywpOvioQs7S7Ft/KINGDOM?node-id=245%3A0
* Developer Handbook: https://coda.io/d/Developer-Handbook_dTZ3jTKljQc
* Development key: d894a09f542da8bd61fc608a2a975093

## Setting up
* rails 6.1.3, ruby 2.7.2, postgreSQL
* rails db:setup 
* rails db:migrate
* bundle install
* If you get this error
<img width="869" alt="Screen Shot 2021-05-18 at 8 28 53 AM" src="https://user-images.githubusercontent.com/48866932/118660008-6b2be580-b7b3-11eb-9be1-469b976af0a5.png">
* Run "yarn" in the terminal 


## Basic Test Accounts
Twilio Development account:
* Email: boxdevlab.auth@gmail.com
* Password: PAssW0Rd!?!!99876

Stripe Development account:
* Email: boxdevlab.auth@gmail.com
* Password: PAssW0Rd!?!!99876

Enom Development account
* -> Ask manager


## Running tests
* Robocup
Just type `rubocop` in a Ruby project's folder and watch the magic happen.
```
$ cd my/cool/ruby/project
$ rubocop
```
To autofix some errors you can run the snippet below. Ensure that your code still runs correctly after using this command.
```
$ rubocop --auto-correct
```
