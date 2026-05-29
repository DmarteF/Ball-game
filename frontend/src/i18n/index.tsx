import React, { createContext, useCallback, useContext, useMemo } from 'react';
import { en, TranslationKey } from './locales/en';
import { ptBR } from './locales/pt-BR';
import { es } from './locales/es';
import { zhCN } from './locales/zh-CN';
import { ja } from './locales/ja';
import { ko } from './locales/ko';
import { fr } from './locales/fr';
import { de } from './locales/de';

export const DEFAULT_LANGUAGE = 'en';

export const SUPPORTED_LANGUAGES = [
  { code: 'en', label: 'English' },
  { code: 'pt-BR', label: 'Português' },
  { code: 'es', label: 'Español' },
  { code: 'zh-CN', label: '中文' },
  { code: 'ja', label: '日本語' },
  { code: 'ko', label: '한국어' },
  { code: 'fr', label: 'Français' },
  { code: 'de', label: 'Deutsch' },
] as const;

export type LanguageCode = typeof SUPPORTED_LANGUAGES[number]['code'];

const resources: Record<LanguageCode, Partial<Record<TranslationKey, string>>> = {
  en,
  'pt-BR': ptBR,
  es,
  'zh-CN': zhCN,
  ja,
  ko,
  fr,
  de,
};

type TranslateParams = Record<string, string | number>;

type I18nContextValue = {
  language: LanguageCode;
  setLanguage: (language: LanguageCode) => Promise<void> | void;
  t: (key: TranslationKey, params?: TranslateParams) => string;
};

const I18nContext = createContext<I18nContextValue>({
  language: DEFAULT_LANGUAGE,
  setLanguage: () => undefined,
  t: key => en[key] || key,
});

export const isSupportedLanguage = (value: unknown): value is LanguageCode =>
  typeof value === 'string' && SUPPORTED_LANGUAGES.some(language => language.code === value);

export const normalizeLanguage = (value: unknown): LanguageCode =>
  isSupportedLanguage(value) ? value : DEFAULT_LANGUAGE;

export const translate = (language: LanguageCode, key: TranslationKey, params?: TranslateParams) => {
  const template = resources[language]?.[key] || en[key] || key;
  if (!params) return template;
  return Object.entries(params).reduce(
    (text, [name, value]) => text.replace(new RegExp(`{{\\s*${name}\\s*}}`, 'g'), String(value)),
    template,
  );
};

export function I18nProvider({
  children,
  language,
  setLanguage,
}: {
  children: React.ReactNode;
  language: LanguageCode;
  setLanguage: (language: LanguageCode) => Promise<void> | void;
}) {
  const normalizedLanguage = normalizeLanguage(language);
  const t = useCallback(
    (key: TranslationKey, params?: TranslateParams) => translate(normalizedLanguage, key, params),
    [normalizedLanguage],
  );
  const value = useMemo(() => ({ language: normalizedLanguage, setLanguage, t }), [normalizedLanguage, setLanguage, t]);

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

export const useTranslation = () => {
  const context = useContext(I18nContext);
  return {
    ...context,
    languages: SUPPORTED_LANGUAGES,
  };
};

export type { TranslationKey };
