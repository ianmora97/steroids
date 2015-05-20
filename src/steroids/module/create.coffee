chalk = require 'chalk'
fs = require 'fs'
path = require 'path'

Help = require '../Help'
sbawn = require '../sbawn'

module.exports = createModule = (argv) ->
  Promise.resolve(argv)
    .then(parseCreateArgs)
    .then(createModuleProject)

parseCreateArgs = (argv) ->
  [section, command, moduleName] = argv._
  repoUrl = argv['repo-url'] || ""

  unless moduleName?
    throw new Error """
      Module name not defined. Please run again with the module name as an argument.
    """

  { moduleName, repoUrl }

createModuleProject = ({ moduleName, repoUrl }) ->
  steroidsCli.debug "Creating a new Appgyver Enterprise Module in #{chalk.bold fullPath}..."

  fullPath = path.join process.cwd(), moduleName
  if fs.existsSync fullPath
    Help.error()
    steroidsCli.log "Directory #{chalk.bold(moduleName)} already exists. Remove it to continue."
    process.exit(1)

  new Promise (resolve, reject) ->
    session = sbawn
      cmd: path.join paths.scriptsDir, "createModuleProject.sh"
      args: [moduleName, repoUrl]
      stdout: true
      stderr: true

    session.on 'exit', ->
      if session.code != 0 || session.stdout.match(/npm ERR!/)
        reject new Error "Something went wrong!"

      resolve()