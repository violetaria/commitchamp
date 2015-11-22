# Commitchamp

A program that allows the user to choose an organization and repository (or all repositories under an organization) and calculate who committed the most!

## Usage

To run, use bundle!  `bundle exec ruby lib/commitchamp.rb`

Users must enter their Github API Authorization Token to use the application.

Example output

```
Enter owner or organization: rails
Enter repository (leave blank for all repos): rails

Choose a sort order:
  (A) Lines Added
  (D) Lines Deleted
  (C) Lines Changed
  (T) Total Commits
a

### Contributions for 'rails/rails'
##  Ordered by adds

Username             Additions Deletions   Changes   Commits
lifo                    362202    380035    742237       753
dhh                     202926    103798    306724      3429
josevalim               179041    185469    364510      1530
jeremy                  134350    111290    245640      3194
josh                    123271    133652    256923      1084
gbuesing                100657     81856    182513       129
fxn                      80257    104411    184668      1541
sikachu                  55274     59094    114368       196
FooBarWidget             52309     48981    101290        96
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/violetaria/commitchamp. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

