# Assembla command line interface to API


Set environment variables with values from [API section][1]:
```shell
export ASSEMBLA_API_KEY='key'
export ASSEMBLA_API_KEY='secret'
```

Clone master repository and configure it.

```shell
git clone git@git.assembla.com:my_project.git
git config assembla.space my_project

# Configure forked repository
# where git-2 is the url part from the web browser location.
assembla_cli setup fork git-2

# create new branch
assembla_cli f ticket_147

# work and commit your changes
git commit -a -m "Awesome feature"

# it will push changes to remote fork and will create a new MR using API
assembla_cli new mr

# Add some fixes after code review, commit them
git commit -a -m "Changes after code review"

# It create a new MR version using API
assembla_cli new ver
```

You can also add a shell alias to type fewer chars:
```shell
alias a=assembla_cli
```

[1]: https://www.assembla.com/user/edit/manage_clients
