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

const getReleases = async ({ githubPrivateKey, owner, repo }: Options) => {
  const appOctokit = await authenticate({ githubPrivateKey, owner, repo })

  const releases: Releases = await appOctokit.rest.repos.listReleases({
    owner,
    repo
  })
  return releases.data
}

const promoteReleases = async ({ githubPrivateKey, owner, repo }: Options) => {
  const releases = await getReleases({ githubPrivateKey, owner, repo })
  const preReleases = releases.filter(release => release.prerelease)
  const appOctokit = await authenticate({ githubPrivateKey, owner, repo })
  await Promise.all(
    preReleases.map(async preRelease => {
      await appOctokit.rest.repos.updateRelease({
        owner,
        repo,
        release_id: preRelease.id,
        prerelease: false,
        make_latest: preRelease.id === releases[0]?.id ? 'true' : 'false',
      })
    })
  )
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
      await promoteReleases(options)
    } catch (e) {
      console.error(e)
      process.exit(1)
    }
  })

program.parse(process.argv)
