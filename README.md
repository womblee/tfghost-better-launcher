# Better TFGhost Launcher
This is a PowerShell script which makes the launch of TFGhost more stable &amp; better

# Bonus
Also disables CPU0 automatically for 30% increase in performance

# How to use
**1.** Open 'launcher.ps1' in any text editor.

**2.** Change '$ghostExecName' to the name of your TFGhost's executable. (without the .exe)

**3.** Change '$ghostPath' to the folder with the TFGhost executable inside.

**4.** Verify that you changed everything correctly:

![image](https://github.com/womblee/tfghost-better-launcher/assets/52250786/25d79892-1d36-4e72-9b73-f09280af9c20)

- If you have any errors, the program will tell you.

**Must know:** The script automatically sets the affinity of the game in 15 seconds after launching everything, if this is not enough for you and your game opens up slowly:
- You can change '$waitTimeBeforeGameOpens = 15' to some other value, like 20 or 25...
