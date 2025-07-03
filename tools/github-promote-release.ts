import { Octokit } from '@octokit/rest'
import { GetResponseTypeFromEndpointMethod } from '@octokit/types'
import { program } from 'commander'

import authenticate from './github-authentication.js'

const octokit = new Octokit()
type Releases = GetResponseTypeFromEndpointMethod<typeof octokit.repos.listReleases>

type Options = {
  githubPrivateKey: string
  owner: string
  repo: string
}

const getReleaseId = async ({ githubPrivateKey, owner, repo }: Options) => {
  const appOctokit = await authenticate({ githubPrivateKey, owner, repo })

  const releases: Releases = await appOctokit.rest.repos.listReleases({ owner, repo })

  const release = releases.data[0]
  if (release && release.prerelease) {
    console.log('Unset prerelease tag of ', release.tag_name)
    return release.id
  }

  console.log('No release found to unset the prerelease tag for. Latest release may already be non-prerelease')
  return null
}

const removePreRelease = async ({ githubPrivateKey, owner, repo }: Options) => {
  const releaseId = await getReleaseId({ githubPrivateKey, owner, repo })
  if (releaseId !== null) {
    const appOctokit = await authenticate({ githubPrivateKey, owner, repo })
    const result = await appOctokit.rest.repos.updateRelease({
      owner,
      repo,
      release_id: releaseId,
      prerelease: false,
      make_latest: 'true'
    })
    console.log('Http response code of updating the result: ', result.status)
  }
}

program
  .command('promote')
  .description('Remove pre-release flag from the latest release')
  .requiredOption(
    '--github-private-key <github-private-key>',
    'private key of the github release bot in pem format with base64 encoding'
  )
  .requiredOption('--owner <owner>', 'owner of the current repository, usually verdigado')
  .requiredOption('--repo <repo>', 'the current repository, should be gruene_app')
  .action(async (options: Options) => {
    try {
      await removePreRelease(options)
    } catch (e) {
      console.error(e)
      process.exit(1)
    }
  })

program.parse(process.argv)
