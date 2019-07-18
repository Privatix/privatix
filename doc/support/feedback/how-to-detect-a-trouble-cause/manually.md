# Manually

1. Find the path the application has been installed in \(eg `app_path=/Applications/Privatix`\)
2. Analyze logs and configs that are located in the following folders:
   1. `${app_path}/log`
   2. `${app_path}/dappctrl`
   3. `${app_path}/tor`
   4. `${app_path}/product/`
3. Analyze database data. Database access credentials you may take from: `${app_path}/dappctrl/dappctrl.config.json`
4. If necessary, you can access the application via CLI: `${app_path}/util/cli`

