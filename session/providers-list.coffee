`import FormProvider from '../../utils/session/form-provider'`
`import StorageProvider from '../../utils/session/storage-provider'`
`import FacebookProvider from '../../utils/session/facebook-provider'`
`import FacebookNativeProvider from '../../utils/session/facebook-native-provider'`
`import TokenProvider from '../../utils/session/token-provider'`
`import ProfileProvider from '../../utils/session/profile-provider'`
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
