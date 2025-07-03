const VERSION_FILE = 'version.yaml'
const MAIN_BRANCH = 'main'

type ReleaseInformation = {
  versionName: string
}
const tagId = ({ versionName }: ReleaseInformation): string => versionName
export {
  VERSION_FILE,
  MAIN_BRANCH,
  tagId
}
