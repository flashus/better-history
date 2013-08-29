window.errorTracker = new BH.Trackers.ErrorTracker(Honeybadger)
window.analyticsTracker = new BH.Trackers.AnalyticsTracker(_gaq)

window.syncStore = new BH.Lib.SyncStore
  chrome: chrome
  tracker: analyticsTracker

syncStore.migrate(localStorage)

new BH.Lib.DateI18n().configure()

settings = new BH.Models.Settings({})
state = new BH.Models.State({}, settings: settings)
settings.fetch
  success: =>
    state.fetch
      success: =>
        state.updateRoute()

        window.router = new BH.Router
          settings: settings
          state: state
          tracker: analyticsTracker

        Backbone.history.start()

syncStore.get ['mailingListPromptTimer', 'mailingListPromptSeen'], (data) ->
  mailingListPromptTimer = data.mailingListPromptTimer || 3
  mailingListPromptSeen = data.mailingListPromptSeen
  unless mailingListPromptSeen?
    if mailingListPromptTimer == 1
      new BH.Views.MailingListView().open()
      syncStore.remove 'mailingListPromptTimer'
      syncStore.set mailingListPromptSeen: true
      analyticsTracker.mailingListPrompt()
    else
      syncStore.set mailingListPromptTimer: (mailingListPromptTimer - 1)
