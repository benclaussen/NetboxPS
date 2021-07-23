# NetboxPS
###### Powershell Netbox API module

# Disclaimer
This module is beta. Use it at your own risk. I have only added functions as I have needed them, so not everything is available.

All functions are exported at the moment, including internal/private functions.

# Description
This module is a wrapper for the [Netbox](https://github.com/netbox-community/netbox) API.

# Usage
1. Install module from the `netboxPS` folder
2. Import module
3. Connect to an API endpoint by using `Connect-NetboxAPI -Hostname netbox.example.com`

# Notes
I started this project years ago with Powershell Studio using the built in deployment methods, learning Git, and learning PS best practices. So please forgive any "obvious" mistakes 😅
Over time I have had to adjust my methods for deployment... change the design of functions, and refactor code as I learn new and better things. 

This was built out of a need at my job to interact with Netbox for automation. Only recently has it become a "public" project with other collaborators (which I truly appreciate!).
I have done my best to ensure each function does exactly one thing according to the API. 

I will do my best to keep up, but please understand it is given attention as I can at work. As time permits, I will open issues for TODOs for things I have wanted to do for a while, just haven't had time or enough "need" to do them.

# Contributing
- Follow [Powershell Practice and Style Guidelines](https://poshcode.gitbook.io/powershell-practice-and-style/) when writing code
- Use discussions for general questions
- Open issues for bug fixes or enhancements
- Submit all pull requests against the dev branch

I am always open to suggestions for improvement with reasons and data to back up the suggestion.