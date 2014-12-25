`import FormProvider from 'ccquest/utils/session/form-provider'`
`import StorageProvider from 'ccquest/utils/session/storage-provider'`
`import FacebookProvider from 'ccquest/utils/session/facebook-provider'`
`import FacebookNativeProvider from 'ccquest/utils/session/facebook-native-provider'`
`import TokenProvider from 'ccquest/utils/session/token-provider'`
`import ProfileProvider from 'ccquest/utils/session/profile-provider'`
`import Ember from 'ember'`

fbProvider = if document.location.protocol is 'file:' or document.location.protocol is 'content:'
              FacebookNativeProvider
            else
              FacebookProvider

ProvidersList = Ember.Object.create
  form: FormProvider.create()
  storage: StorageProvider.create()
  facebook: fbProvider.create()
  token: TokenProvider.create()
  profile: ProfileProvider.create()

`export default ProvidersList`
