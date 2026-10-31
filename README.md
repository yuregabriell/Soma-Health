# SŌMA Health

Aplicação Android **independente do ecossistema Vista**. Flutter, sem conta obrigatória.

## v0.3.0 — Beta nutricional

- Treinos guiados (circuitos de 30 segundos com pausas de 15 segundos) e ambientes casa/ginásio.
- Onboarding, registo de peso, evolução, sono, humor, água e glicemia anotada a partir de um medidor externo.
- Diário alimentar com fotografia opcional guardada no dispositivo, registos que podem ser eliminados e totais de macronutrientes.
- Biblioteca alimentar offline com 24 alimentos e porções configuráveis.
- Pesquisa online de alimentos por produto/marca no **Open Food Facts**.
- Leitor de código de barras Android e alternativa para inserir o código manualmente.
- Cálculos de energia, proteína, hidratos, gorduras e açúcares com dados por 100 gramas.
- Histórico de água e lembretes locais opcionais (5 horários por dia, agendados por 21 dias e renovados ao abrir).

### Limitações importantes

**Não está terminado.** A análise de alimentos por fotografia no ChatGPT não está integrada. A fotografia guardada no diário não é analisada automaticamente. O módulo de treinos ainda precisa de exercícios instruídos, planos progressivos de cargas/séries e provas em dispositivos reais. As notificações podem sofrer atrasos por otimizações de bateria e precisam de renovação ao abrir após 21 dias.

**Dados de saúde:** guardados localmente em SharedPreferences sem encriptação específica de dados clínicos. Não introduzas informação médica sensível nesta beta. Não há exportação de segurança ou sincronização; reinstalar poderá apagar dados.

**Nutrição:** os números são estimativas, não medições. Alguns produtos Open Food Facts têm campos em falta; o app assinala tabelas incompletas. Confirma o rótulo.

**Glicemia:** o app não mede glicose; aceita apenas registo manual de um medidor externo.

**Assinatura:** GitHub Actions usa por agora a configuração de build experimental; atualizações APK podem exigir remoção da versão anterior com perda de dados. Ainda falta assinatura estável de distribuição.

### Fontes e licenças

- [Open Food Facts](https://world.openfoodfacts.org): dados nutricionais **ODbL**; fotografias/produtos têm licenças próprias. Usa-se uma consulta de leitura, sem distribuir uma cópia agregada da base. Atribuição na aplicação e aqui.
- [mobile_scanner](https://pub.dev/packages/mobile_scanner), licença BSD-3-Clause.
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications), licença BSD-3-Clause.
- [OpenNutriTracker](https://github.com/simonoppowa/OpenNutriTracker), GPL-3.0 — **referência conceptual**, código não copiado.
- [OpenGym](https://github.com/DuarteSantos8/openGym), AGPL-3.0 — **referência conceptual**, código e recursos não incorporados.
- [Plees Tracker](https://github.com/vmiklos/plees-tracker), BSD — referência conceptual.
- [Moodiary](https://github.com/ZhuJHua/moodiary), AGPL — referência conceptual.
- [Medito](https://github.com/meditohq/medito-app), AGPL — referência conceptual, sem redistribuição de áudios.

### Releases

[Ver APKs publicados](https://github.com/yuregabriell/Soma-Health/releases). O APK só deve ser utilizado quando a execução Android CI correspondente estiver com sucesso.
