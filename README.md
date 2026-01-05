![](/images/pssm-gear-icon-x128.png)  
  
# PSSM
Another service manager for Microsoft Windows.

> ⚠️  **WARNING**:
> This is for educational purposes only. It should not be considered production-ready, best-practice, etc. You should fully understand code before you run it on your system, and you should have authorization to run code on your system.

## Getting Started
You can download the latest version from the [releases page](https://github.com/griffeth-barker/PSSM/releases).

The latest release SHA256 hash is: 
```sha256-hash
33791DA9885254D80E1467AF43C29FF626F0B9AE63207F58C2728DACE994F696
```

## Features
  - Listing services
  - Exporting list of services as CSV file or JSON string
  - Checking if service executable paths are hardened (in quotations)
  - Checking if service executable directory permissions are overly permissive
  - Opening the service's relevant registry key and executable location
  - Start, stop, and restart services
  - Install and delete services

## Future Plans?
  - Ability to harden service executable paths
  - Ability to harden service executable directory ACLs
  - Ability to connect to a remote computer to manage its services

## Feedback  
Please ⭐ star this repository if it is helpful. Constructive feedback is always welcome, as are pull requests.
Feel free to open an issue on the repository if needed.