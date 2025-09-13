package utils

import (
	"embed"
	"encoding/json"
	"github.com/nicksnyder/go-i18n/v2/i18n"
	"golang.org/x/text/language"
)

//go:embed locales/*.json
var LocaleFS embed.FS

type SingletonTranslationManager struct {
	bundle i18n.Bundle
}

var translationManager *SingletonTranslationManager

func GetTranslationManager() *SingletonTranslationManager {
	if translationManager == nil {
		bundle := i18n.NewBundle(language.English)
		bundle.RegisterUnmarshalFunc("json", json.Unmarshal)
		locales, _ := LocaleFS.ReadDir("locales")
		for _, file := range locales {
			bundle.LoadMessageFile("locales/" + file.Name())
		}

		translationManager = &SingletonTranslationManager{
			bundle: *bundle,
		}
	}
	return translationManager
}

func translate(lang, messageID string) string {
	tm := GetTranslationManager()
	localizer := i18n.NewLocalizer(&tm.bundle, lang)
	translated, err := localizer.Localize(&i18n.LocalizeConfig{
		MessageID: messageID,
	})
	if err != nil {
		return messageID // Fallback to messageID if translation fails
	}
	return translated
}
