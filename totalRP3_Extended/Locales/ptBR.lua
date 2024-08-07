-- Copyright The Total RP 3 Extended Authors
-- SPDX-License-Identifier: Apache-2.0

-- THIS FILE IS AUTOMATICALLY GENERATED.
-- ALL MODIFICATIONS TO THIS FILE WILL BE LOST.

local L;

L = {
	["ALL"] = "Tudo",
	["BINDING_NAME_TRP3_INVENTORY"] = "Abrir o inventário do personagem",
	["BINDING_NAME_TRP3_MAIN_CONTAINER"] = "Abrir bolsa principal",
	["BINDING_NAME_TRP3_QUEST_ACTION"] = "Ação da missão: Interação",
	["BINDING_NAME_TRP3_QUEST_LISTEN"] = "Ação da missão: Escutar",
	["BINDING_NAME_TRP3_QUEST_LOOK"] = "Ação da missão: Inspecionar",
	["BINDING_NAME_TRP3_QUEST_TALK"] = "Ação da missão: Falar",
	["BINDING_NAME_TRP3_QUESTLOG"] = "Abrir registro de missões do TRP3",
	["BINDING_NAME_TRP3_SEARCH_FOR_ITEMS"] = "Procurar por itens",
	["CA_ACTION_CONDI"] = "Editor de condição para ação",
	["CA_ACTION_REMOVE"] = "Remover essa ação?",
	["CA_ACTIONS"] = "Ações",
	["CA_ACTIONS_ADD"] = "Adicionar ação",
	["CA_ACTIONS_COND"] = "Mudar condição",
	["CA_ACTIONS_COND_OFF"] = "Esse ação não é condicionado",
	["CA_ACTIONS_COND_ON"] = "Esse ação é condicionado",
	["CA_ACTIONS_COND_REMOVE"] = "Remover condição",
	["CA_ACTIONS_EDITOR"] = "Editor de ação",
	["CA_ACTIONS_NO"] = "Sem ação",
	["CA_ACTIONS_SELECT"] = "Seleciona o tipo de ação",
	["CA_DESCRIPTION"] = "Sumário de campanha",
	["CA_DESCRIPTION_TT"] = "Este breve resumo estará visível na página da campanha, no registro de missões.",
	["CA_ICON"] = "Ícone da campanha",
	["CA_ICON_TT"] = "Selecione ícone de campanha",
	["CA_IMAGE"] = "Imagem da campanha",
	["CA_IMAGE_TT"] = "Selecione o “retrato” da campanha",
	["CA_LINKS_ON_START"] = "No começo da campanha",
	["CA_LINKS_ON_START_TT"] = [=[Ativado |cff00ff00 uma vez |r quando o jogador começa a campanha, como ativando-a pela primeira vez, ou reiniciando o registro de missões.

|cff00ff00Esse é uma bom local para ativar a sua primeira missão.]=],
	["CA_NAME"] = "Nome da campanha",
	["CA_NAME_NEW"] = "Nova campanha",
	["CA_NAME_TT"] = "Esse é o nome da sua campanha. Isso aparecerá no seu registro de missões.",
	["CA_NO_NPC"] = "Sem NPC personalizado",
	["CA_NPC"] = "Lista de NPC da campanha",
	["CA_NPC_ADD"] = "Adicionar NPC personalizado",
	["CA_NPC_AS"] = "Duplicado",
	["CA_NPC_EDITOR"] = "Editor de NPC",
	["CA_NPC_EDITOR_DESC"] = "Descrição do NPC",
	["CA_NPC_EDITOR_NAME"] = "Nome do NPC",
	["CA_NPC_ID"] = "ID do NPC",
	["CA_NPC_ID_TT"] = [=[Por favor, coloque o ID do NPC para personalizar.

|cff00ff00Para obter o ID do NPC que você marcou como alvo, ditite no chat: /trp3 GetID]=],
	["CA_NPC_NAME"] = "Nome padrão do NPC",
	["CA_NPC_REMOVE"] = "Remover a personalização deste NPC?",
	["CA_NPC_TT"] = "Você pode personalizar NPCs para dar para eles um nome, um ícone e uma descrição. Essa personalização vai ser visível quando o jogador está com a sua campanha como ativa.",
	["CA_NPC_UNIT"] = "NPC Personalizado",
	["CA_QE_ID"] = "Mudar o ID da missão",
	["CA_QE_ST_ID"] = "Mudar o ID do passo da missão",
	["CA_QUEST_ADD"] = "Adicionar missão",
	["CA_QUEST_CREATE"] = [=[Por favor, coloque o ID da missão. Você não pode ter duas missões com o mesmo ID na mesma campanha.

|cffff9900Por favor, note que a missão vai ser listada em ordem alfabética dos IDs no registro de missões

|cff00ff00É uma boa pratica sempre começar seu ID com "quest_", com o numero da missão na campanha.]=],
	["CA_QUEST_DD_COPY"] = "Copiar conteúdo da missão",
	["CA_QUEST_DD_PASTE"] = "Colar conteúdo da missão",
	["CA_QUEST_DD_REMOVE"] = "Remover missão",
	["CA_QUEST_EXIST"] = "Já existe uma missão com o ID %s",
	["CA_QUEST_NO"] = "Sem missões",
	["CA_QUEST_REMOVE"] = "Remover essa missão?",
	["CL_CAMPAIGN_PROGRESSION"] = "Progressão do %s:",
	["CL_CREATION"] = "Criação estendida",
	["CL_EXTENDED_CAMPAIGN"] = "Campanha estendida",
	["CL_EXTENDED_ITEM"] = "Item estendido",
	["CL_IMPORT"] = "Importar para o banco de dados",
	["CL_IMPORT_ITEM_BAG"] = "Adicionar item na sua bolsa",
	["CL_TOOLTIP"] = "Criar link no chat",
	["COM_NPC_ID"] = "Obter o ID do NPC que foi marcado como alvo",
	["COND_COMPLETE"] = "Completar a expressão logica",
	["COND_CONDITIONED"] = "Condicionado",
	["COND_EDITOR"] = "Editor de condição",
	["COND_EDITOR_EFFECT"] = "Editor de condição para efeito",
	["COND_LITT_COMP"] = "Todos os tipos de comparação",
	["COND_NUM_COMP"] = "Somente comparação numérica",
	["COND_NUM_FAIL"] = "Você deve ter dois operadores numéricos, se você usa um comparador numérico",
	["COND_PREVIEW_TEST"] = "Teste anterior",
	["COND_PREVIEW_TEST_TT"] = "Imprime na interface de chat a avaliação desse teste baseada na situação atual.",
	["COND_TEST_EDITOR"] = "Editor de teste",
	["COND_TESTS"] = "Condição para testes",
	["CONF_MAIN"] = "Extended",
	["CONF_MUSIC_ACTIVE"] = "Tocar musica local",
	["CONF_MUSIC_ACTIVE_TT"] = [=[Musicas locais são musicas tocadas por outros jogadores (por exemplo: através de um item) em um certo limite de distância.

Desligue isso, se você não quer ouvir aquelas musicas.

|cnWARNING_FONT_COLOR:Note que você nunca irá escutar musicas de jogadores ignorados|r

|cnGREEN_FONT_COLOR:Note que todas as musicas são interruptivos via "Sound History" na barra de tarefa do TRP3|r]=],
	["CONF_MUSIC_METHOD"] = "Método de tocar a musica local",
	["CONF_MUSIC_METHOD_TT"] = "Determine como você vai escutar a musica local, quando você estiver dentro do alcance.",
	["CONF_SOUNDS"] = "Sons/musicas locais",
	["CONF_SOUNDS_ACTIVE"] = "Tocar sons locais",
	["CONF_SOUNDS_ACTIVE_TT"] = [=[Sons locais são tocados por outros jogadores (por exemplo: através um item), quando estiver dentro de um certo alcance.

Desligue isso se você não quer escutar esse som.

|cnWARNING_FONT_COLOR:Note que você não vai escutar sons de jogadores ignorados.|r

|cnGREEN_FONT_COLOR:Note que todos os sons são interruptíveis via "Sound History" na barra de tarefa do TRP3|r]=],
	["CONF_SOUNDS_MAXRANGE"] = "Alcance máximo do \"playback\"",
	["CONF_SOUNDS_MAXRANGE_TT"] = [=[Configura o alcance máximo (em metros), para escutar sons/musicas locais.

|cnGREEN_FONT_COLOR:Útil para evitar pessoas tocando sons através de todo o continente.|r

|cnWARNING_FONT_COLOR:Zero significa sem limite!|r]=],
	["CONF_SOUNDS_METHOD"] = "Método para tocar sons locais",
	["CONF_SOUNDS_METHOD_1"] = "Tocar automaticamente",
	["CONF_SOUNDS_METHOD_1_TT"] = "Se dentro do alcance, irá tocar o som/musica sem perguntar sua permissão.",
	["CONF_SOUNDS_METHOD_2"] = "Perguntar por permissão",
	["CONF_SOUNDS_METHOD_2_TT"] = "Se você estiver dentro do alcance, um link será colocado na interface do seu chat perguntando sua confirmação para tocar o som/musica.",
	["CONF_SOUNDS_METHOD_TT"] = "Determina como você vai escutar um som local, quando você estiver dentro do alcance.",
	["CONF_UNIT"] = "Unidades",
	["CONF_UNIT_WEIGHT"] = "Peso da unidade",
	["CONF_UNIT_WEIGHT_1"] = "Gramas",
	["CONF_UNIT_WEIGHT_2"] = "Libras",
	["CONF_UNIT_WEIGHT_3"] = "Batatas",
	["CONF_UNIT_WEIGHT_TT"] = "Defina como o valor do peso é mostrado",
	["DB"] = "Banco de dados",
	["DB_ACTIONS"] = "Ações",
	["DB_ADD_COUNT"] = "Quantas unidades de %s você quer adicionar em seu inventario?",
	["DB_ADD_ITEM"] = "Adicionar para o inventário principal",
	["DB_ADD_ITEM_TT"] = "Adiciona unidades desse item na sua bolsa primaria (ou inventário principal, se você não tem uma bolsa primaria no seu personagem)",
	["DB_BACKERS"] = "Banco de dados dos apoiadores (%s)",
	["DB_BACKERS_LIST"] = "Creditos",
	["DB_BROWSER"] = "Navegador de objetos",
	["DB_COPY_ID_TT"] = "Mostrar o ID do objeto no popup para copiado/colado",
	["DB_COPY_TT"] = "Copiar informações para este objeto (e objetos \"filhos\") para ser colável como uma ligação em outro objeto.",
	["DB_CREATE_CAMPAIGN"] = "Criar campanha",
	["DB_CREATE_CAMPAIGN_TEMPLATES_BLANK"] = "Campanha vazia",
	["DB_CREATE_CAMPAIGN_TEMPLATES_BLANK_TT"] = "Uma página em branco. Para aqueles que gostam de começar de um rascunho.",
	["DB_CREATE_CAMPAIGN_TEMPLATES_FROM"] = "Criar de...",
	["DB_CREATE_CAMPAIGN_TEMPLATES_FROM_TT"] = "Criar uma copia de uma campanha existente",
	["DB_CREATE_CAMPAIGN_TT"] = "Começar a criar uma campanha",
	["DB_CREATE_ITEM"] = "Criar item",
	["DB_CREATE_ITEM_TEMPLATES"] = "Ou selecionar um modelo",
	["DB_CREATE_ITEM_TEMPLATES_BLANK"] = "Item vazio",
	["DB_CREATE_ITEM_TEMPLATES_BLANK_TT"] = "Uma página em branco. Para aqueles que gostam de começar de um rascunho.",
	["DB_CREATE_ITEM_TEMPLATES_CONTAINER"] = "Bolsa de itens",
	["DB_CREATE_ITEM_TEMPLATES_CONTAINER_TT"] = "Uma bolsa em branco. Bolsas podem segurar outros itens.",
	["DB_CREATE_ITEM_TEMPLATES_DOCUMENT"] = "Um item de documento",
	["DB_CREATE_ITEM_TEMPLATES_DOCUMENT_TT"] = "Um modelo de item com um objeto de documento interno. Ótimo para rapidamente criar um livro ou um pergaminho.",
	["DB_CREATE_ITEM_TEMPLATES_EXPERT"] = "Item expert",
	["DB_CREATE_ITEM_TEMPLATES_EXPERT_TT"] = "Um modelo Expert em branco. Para usuários com experiência em fazer criações.",
	["DB_CREATE_ITEM_TEMPLATES_FROM"] = "Criar de...",
	["DB_CREATE_ITEM_TEMPLATES_FROM_TT"] = "Cria uma cópia de um item existente.",
	["DB_CREATE_ITEM_TEMPLATES_QUICK"] = "Criação rápida",
	["DB_CREATE_ITEM_TEMPLATES_QUICK_TT"] = "Rapidamente cria um item simples sem qualquer efeito Então adiciona uma unidade desse item na sua bolsa primária.",
	["DB_CREATE_ITEM_TT"] = "Selecione um modelo para um novo item",
	["DB_DELETE_TT"] = "Remove esse objeto e todos seus objetos filhos.",
	["DB_EXPERT_TT"] = "Troca este objeto para modo expert, permitindo customizações mais complexas.",
	["DB_EXPORT"] = "Exportação rápida de objeto",
	["DB_EXPORT_DONE"] = "seu objeto foi exportado no arquivo chamado |cff00ff00totalRP3_Extended_ImpExport.lua|r Neste diretório de jogo: World of Warcraft\\WTF\\ account\\YOUR_ACCOUNT\\SavedVariables Você pode compartilhar este arquivo com seus amigos!! eles podem seguir o processo de importação na|cff00ff00 aba de base de arquivos|r.",
	["DB_EXPORT_HELP"] = "Código para objeto %s (tamanho: %0.1f kB)",
	["DB_EXPORT_MODULE_NOT_ACTIVE"] = "Exportação/importação completa do objeto: por favor ative primeiro o complemento totalRP3_Extended_ImpExport.",
	["DB_EXPORT_TOO_LARGE"] = "Este objeto é muito grande uma vez para ser numerado para ser exportado desta forma. Por favor use  o modo de exportação completo. Tamanho: %0.1f kB.",
	["DB_EXPORT_TT"] = "Numera o conteúdo do objeto para ser trocado fora do jogo. Funciona apenas em objetos pequenos (menos de 20 kB depois de numerado). Para objetos maiores, use o recurso de exportação completa.",
	["DB_FILTERS"] = "Encontrar filtros",
	["DB_FILTERS_CLEAR"] = "Limpar",
	["DB_FILTERS_NAME"] = "Nome do Objeto",
	["DB_FILTERS_OWNER"] = "Criado por",
	["DB_FULL"] = "Base de dados completa (%s)",
	["DB_FULL_EXPORT"] = "Exportação completa",
	["DB_FULL_EXPORT_TT"] = "Fazer uma exportação completa para este objeto independente de seu tamanho. Isto irá ativar uma recarga da UI em ordem de forçar a escrita do arquivo de salvamento do add-on",
	["DB_HARD_SAVE"] = "Salvamento Difícil",
	["DB_HARD_SAVE_TT"] = "Recarregar a UI do jogo para forçar as variáveis salvas para serem escritas no disco.",
	["DB_IMPORT"] = "Rápida importação de objetos",
	["DB_IMPORT_CONFIRM"] = [=[Este objeto foi serializado em uma versão diferente do Total RP 3 Extended do que o seu.
Importe a versão do TRP3E :%s . Sua versão do TRP3E: %s |cffff9900 Isto pode levar a incompatibilidades. Continuar a importar do mesmo jeito?]=],
	["DB_IMPORT_DONE"] = "Objeto importado corretamente!!",
	["DB_IMPORT_EMPTY"] = [=[Não existe objeto para importar no seu arquivo |cff00ff00totalRP3_Extended_ImpExport.lua|r. 
O arquivo deve ser colocado neste diretório de jogo |cffff9900priorizando o launcher |r: World of Warcraft\WTF\ account\YOUR_ACCOUNT\SavedVariables]=],
	["DB_IMPORT_ERROR1"] = "Este objeto não pode ser 'Des\"serializado.",
	["DB_IMPORT_FULL"] = "Importação completa de objetos",
	["DB_IMPORT_FULL_CONFIRM"] = "Você quer importar os seguintes objetos? %s %s Por |cff00ff00%s|r Versão %ões",
	["DB_IMPORT_FULL_TT"] = "Importar o arquivo |cff00ff00totalRP3_Extended_ImpExport.lua|r. ",
	["DB_IMPORT_ITEM"] = "Importar item",
	["DB_IMPORT_TT"] = "Colar objeto préviamente serializado aqui",
	["DB_IMPORT_VERSION"] = [=[Você está importando uma versão antiga deste objeto do que uma versão que você já tem.
Versão importada: %s  Sua versão : %s  |cffff9900 Você confirma que você quer importar uma versão atrasada?]=],
	["DB_IMPORT_WORD"] = "Importar",
	["DB_LIST"] = "Lista de criações",
	["DB_LOCALE"] = "Local do Objeto",
	["DB_MY"] = "Minha Base de Dados (%s)",
	["DB_MY_EMPTY"] = "Você não tem nenhum objeto criado ainda. Use um dos botões abaixo para desloquear sua criatividade!",
	["DB_OTHERS"] = "Base de dados dos jogadores (%s)",
	["DB_OTHERS_EMPTY"] = "Aqui todos objetos criados por outros jogadores serão colocados.",
	["DB_REMOVE_OBJECT_POPUP"] = [=[Por favor confirme a remoção do objeto: ID: |cff00ffff"%s"|r |cff00ff00[%s]|r |cffff9900 
AVISO: ESTA AÇÃO NÃO PODE SER REVERTIDA!]=],
	["DB_RESULTS"] = "Procurar resultados",
	["DB_SECURITY_TT"] = "Mostra todos parâmetros de segurança para este objeto. Daqui você pode permitir ou previnir certos efeitos indesejados.",
	["DB_TO_EXPERT"] = "Converter para modo expert",
	["DB_WARNING"] = "|cffff0000!!! Aviso !!! |cffff9900Não esqueça de salvar suas mudanças antes de retornar a lista da base de dados ",
	["DEBUG_QUEST_START"] = "Começar missão",
	["DEBUG_QUEST_START_USAGE"] = "Utilização: /trp3 debug_quest_start questID",
	["DEBUG_QUEST_STEP"] = "Ir até um passo de missão.",
	["DEBUG_QUEST_STEP_USAGE"] = "utilização:  /trp3 debug_quest_step questID stepID",
	["DI_ATTR_TT"] = "Somente marque isto se você realmente quer mudar este atributo relativo ao passo da cutscene anterior",
	["DI_ATTRIBUTE"] = "Estágio de modificação",
	["DI_BKG"] = "Mudar a imagem do plano de fundo",
	["DI_BKG_TT"] = "Será usado como fundo para o passo da cutscene. Por favor entre com o caminho da textura completa. Se você mudar o plano de fundo durante uma cutscene terá uma escuridão entre os dois planos de fundo.",
	["DI_CHOICE"] = "Opções",
	["DI_CHOICE_CONDI"] = "Condição de opções",
	["DI_CHOICE_STEP"] = "Vá para o passo",
	["DI_CHOICE_STEP_TT"] = "Entre com o numero do passo da cutscene para tocar se o jogador selecionar esta opção.|cff00ff00If Index vazio ou inválido, isto irá terminar a cutscene se selecionado( e ativado O final do evento do objeto).",
	["DI_CHOICE_TT"] = "Entre com o texto dessa opção. |cff00ff00 Deixe vazio para desativar esta opção.",
	["DI_CHOICES"] = "Escolhas do jogador",
	["DI_CHOICES_TT"] = "Configure as escolhas dos jogadores para este passo",
	["DI_CONDI_TT"] = "Determina a condição para esta opção. Se a condição não esta marcado quando mostrando as opções, A opção associada não será visível. |cff00ff00 Clique esquerdo: Configura Condição Clique direito: Limpar condição",
	["DI_DIALOG"] = "Diálogo",
	["DI_DISTANCE"] = "Máxima distância (metros)",
	["DI_DISTANCE_TT"] = [=[Define a distância máxima (em metros), o jogador pode mover quando a cutscene começou antes de se fechar automaticamente ( e ativar o "em cancelamento" evento de objeto).
|cff00ff00 Zero significa sem limite. |cffff9900 Não funciona em masmorras/campos de batalhas/arenas desde o patch 7.1]=],
	["DI_END"] = "Ponto final",
	["DI_END_TT"] = "Marque este passo como ponto final. Quando alcançado irá terminar a cutscene ( e ativar o terminar evento do objeto). |cff00ff00 usável se você faz escolhas nesta cutscene.",
	["DI_FRAME"] = "Decoração",
	["DI_GET_ID"] = "ID Alvo",
	["DI_GET_ID_TT"] = "Copia a ID do NPC alvo. Somente funciona se seu alvo atual é um NPC.",
	["DI_HISTORY"] = "Histórico de cutscene",
	["DI_HISTORY_TT"] = "Clique para ver/esconder o painel de história, Mostrando as linhas anteriores de cutscenes",
	["DI_IMAGE"] = "Trocar imagem",
	["DI_IMAGE_TT"] = "Mostra a imagem no centro do frame da cutscene. A imagem irá desaparecer. Por favor entre com o caminho completo da textura. Para esconder a imagem depois, somente deixa a caixa vazia.",
	["DI_LEFT_UNIT"] = "Troca o modelo esquerdo",
	["DI_LINKS_ONEND"] = "No final da cutscene",
	["DI_LINKS_ONEND_TT"] = "Ativado quando a cutscene é terminada. |cff00ff00 Isto pode ser feito alcançando o fim do ultimo passo ou por permitir que o jogador selecione uma escolha com ou desconhecido  \"vá para o passo\". |cffff0000 Isto não é ativado se o jogador cancela a cutscente manualmente fechando o frame.",
	["DI_LINKS_ONSTART"] = "No começo da cutscene",
	["DI_LINKS_ONSTART_TT"] = "Ativado quando a cutscente é tocada. |cffff9900 note que este fluxo de trabalho irá ser tocado ANTES mostrando o primeiro passo.",
	["DI_LOOT"] = "Espere pelo loot!",
	["DI_LOOT_TT"] = "Se o fluxo de trabalho selecionado no lado esquerdo da tela irá mostrar o loot para o jogador, você pode marcar esse parâmentro para prevenir que o jogador vá para a próxima cutscente até ter pegado o loot de todos os itens.",
	["DI_MODELS"] = "MODELOS",
	["DI_NAME"] = "Trocar o nome de quem fala",
	["DI_NAME_DIRECTION"] = "Mudar a direção do diálogo",
	["DI_NAME_DIRECTION_TT"] = "Determina onde colocar a bolha de/nome de chat e qual modelo animar. Selecione nada para completamente esconder a bolha de chat e nome.",
	["DI_NAME_TT"] = "O nome do personagem que fala. Somente necessário se a direção do dialogo acima não é NENHUM",
	["DI_NEXT"] = "Index do próximo passo",
	["DI_NEXT_TT"] = "Você pode indicar qual passo irá ser tocado depois desta. |cff00ff00 deixe vazio para tocar o próximo index em ordem sequencial, somente use este campo se você precisa \"pular\" para outro index. facilita quando estiver usando escolhas.",
	["DI_RIGHT_UNIT"] = "Mudar o modelo direito",
	["DI_STEP"] = "Passo da cutscene",
	["DI_STEP_ADD"] = "Adicionar passo",
	["DI_STEP_EDIT"] = "Edição de passo da cutscene",
	["DI_STEP_TEXT"] = "Texto do passo",
	["DI_STEPS"] = "Passo da cutscene",
	["DI_UNIT_TT"] = "Marca o modelo a mostra: -deixe em branco para esconder o modelo-\"jogador\" para usar o modelo do jogador- \"alvo\" para usar o modelo alvo-Qualquer numero para carregar como uma ID de NPC",
	["DI_WAIT_LOOT"] = "Por favor Pegue todos os itens",
	["DISCLAIMER"] = "{h1:c}Leia{/h1} Criar itens e missões leva tempo e energia e é sempre terrível quando você perde todo o trabalho duro que fez. Todos os complementos no World of Warcraft podem armazenar dados, mas há limitações: • Há um limite de tamanho de dados desconhecido para dados complementares (dependendo do fato de você estar executando um cliente de 32 ou 64 bits, entre outras coisas). • Alcançar esse limite pode apagar todos os dados salvos do complemento. • Matar o processo, forçar o fechamento do cliente do jogo (Alt+F4) ou travar pode corromper os dados salvos do complemento. • Mesmo que você saia do jogo corretamente, sempre há uma chance de que o jogo não consiga salvar os dados do complemento e corrompê-los. Em relação a tudo isso, recomendamos FORTEMENTE fazer backup regularmente dos dados salvos do complemento. Você pode encontrar aqui um tutorial sobre como encontrar todos os dados salvos: {link*https://github.com/Total-RP/Total-RP-3/wiki/Saved-Variables*Onde minhas informações estão armazenadas?} Você pode encontrar aqui um tutorial sobre como sincronizar seus dados com um serviço de nuvem : {link*https://github.com/Total-RP/Total-RP-3/wiki/How-to-backup-and-synchronize-your-add-ons-settings-using-a-cloud-service*Como fazer backup e sincronizar suas configurações de complementos usando um serviço de nuvem} Entenda que não responderemos mais a comentários ou tickets relacionados a limpeza de dados. Não é porque não queremos ajudar, mas porque não podemos fazer nada para restaurar os dados apagados. Obrigado e aproveite o Total RP 3 Extended! {p:r}Equipe TRP3{/p}",
	["DISCLAIMER_OK"] = "Eu assino este contrato por meio de meu sangue",
	["DO_EMPTY"] = "Documento vazio",
	["DO_LINKS_ONCLOSE"] = "De perto",
	["DO_LINKS_ONCLOSE_TT"] = "Ativado quando o documento está fechado pelo jogador ou outro evento (e também através de um efeito  de fluxo de trabalho)",
	["DO_LINKS_ONOPEN"] = "Em aberto",
	["DO_LINKS_ONOPEN_TT"] = "Ativado quando o documento é mostrado para o jogador",
	["DO_NEW_DOC"] = "Documento",
	["DO_PAGE_ADD"] = "Adicionar página",
	["DO_PAGE_BORDER"] = "Borda",
	["DO_PAGE_BORDER_1"] = "Pergaminho",
	["DO_PAGE_COUNT"] = "Página %s / %s",
	["DO_PAGE_EDITOR"] = "Editor de página: página %s",
	["DO_PAGE_FIRST"] = "Primeira página",
	["DO_PAGE_FONT"] = "%s fonte",
	["DO_PAGE_HEIGHT"] = "Altura da página",
	["DO_PAGE_HEIGHT_TT"] = "A altura da página, em pixels. Por favor note que certos planos de fundo somente suporta uma certa porcentagem de altura/largura e pode ficar deformada",
	["DO_PAGE_LAST"] = "Ultima página",
	["DO_PAGE_MANAGER"] = "Gerenciador de páginas",
	["DO_PAGE_NEXT"] = "Próxima página",
	["DO_PAGE_PREVIOUS"] = "Página anterior",
	["DO_PAGE_REMOVE"] = "Remover página",
	["DO_PAGE_REMOVE_POPUP"] = "Remover a página %s ?",
	["DO_PAGE_RESIZE"] = "Redimensionável",
	["DO_PAGE_RESIZE_TT"] = "Permite o usuário redimensionar o frame. |cffff9900 esteja certo que o layout pode ser legível e não depende da porcentagem de altura/largura.  |cff00ff00 note que o usuário não irá nunca ser capaz de reduzir o tamanho do frame através do tamanho e largura padrão",
	["DO_PAGE_TILING"] = "Decoração do plano de fundo",
	["DO_PAGE_TILING_TT"] = "Define se o plano de fundo irá decorar verticalmente e horizontalmente. Se não, A textura irá ser esticada.",
	["DO_PAGE_WIDTH"] = "Largura da página",
	["DO_PAGE_WIDTH_TT"] = "A largura da página, em pixels. Por favor note que certos planos de fundo somente suporta certo alcance de alturas e larguras e pode ser deformada",
	["DO_PARAMS_CUSTOM"] = "parâmetros customizadas da página",
	["DO_PARAMS_GLOBAL"] = "Parâmetros padrão",
	["DO_PARAMS_GLOBAL_TT"] = "Troca o documento padrão. Estes parâmetros irão ser usados para todas páginas que nao utilizem parâmetros de páginas customizadas.",
	["DO_PREVIEW"] = "Clique para ver uma Prévia",
	["DOC_UNKNOWN_ALERT"] = "Não pode abrir o documento. (Faltando classe)",
	["DR_DELETED"] = "Destruído: %s x%d",
	["DR_DROP_ERROR_INSTANCE"] = "Não pode soltar itens em uma Masmorra",
	["DR_DROPED"] = "Solto no chão: %s x%d",
	["DR_NOTHING"] = "Nenhum item encontrado nessa área.",
	["DR_POPUP"] = "Solte aqui",
	["DR_POPUP_ASK"] = "Total RP 3 selecione o que acontece com o item: %s",
	["DR_POPUP_REMOVE"] = "Destruir",
	["DR_POPUP_REMOVE_TEXT"] = "Destruir este item?",
	["DR_RESULTS"] = "Encontrado %s itens",
	["DR_SEARCH_BUTTON"] = "Encontrar itens para |cff00ff00my|r",
	["DR_SEARCH_BUTTON_TT"] = "Procurar por seus itens na área entre 15 metros",
	["DR_STASHED"] = "Esconderijos: %s x%d",
	["DR_STASHES"] = "Esconderijos",
	["DR_STASHES_CREATE"] = "crie um esconderijo aqui",
	["DR_STASHES_CREATE_TT"] = "Criar um esconderijo onde você está",
	["DR_STASHES_DROP"] = "Você não pode soltar um item em um esconderijo de alguém",
	["DR_STASHES_EDIT"] = "Editar esconderijo",
	["DR_STASHES_ERROR_INSTANCE"] = "Não pode criar um esconderijo em uma masmorra",
	["DR_STASHES_ERROR_OUT_SYNC"] = "Esconderijo fora de sincronização, por favor tente novamente",
	["DR_STASHES_ERROR_SYNC"] = "Esconderijo não sincronizado.",
	["DR_STASHES_FOUND"] = "Esconderijos encontrado: %s",
	["DR_STASHES_FULL"] = "Este esconderijo está cheio.",
	["DR_STASHES_HIDE"] = "Esconder do scan",
	["DR_STASHES_HIDE_TT"] = "Este esconderijo não aparece no mapa de scan de outros jogadores. note que eles sempre irão ser capazes de acessar se eles souberem onde estão.",
	["DR_STASHES_MAX"] = "Máximo de 50 caracteres",
	["DR_STASHES_NAME"] = "Esconderijo",
	["DR_STASHES_NOTHING"] = "Nenhum esconderijo encontrado nessa área",
	["DR_STASHES_OWNER"] = "Dono",
	["DR_STASHES_OWNERSHIP"] = "Tomar posse",
	["DR_STASHES_OWNERSHIP_PP"] = "Tomar posse deste esconderijo? Este personagem irá ser mostrado como dono desse esconderijo quando outros jogadores escanear por ele.",
	["DR_STASHES_REMOVE"] = "Remover esconderijo",
	["DR_STASHES_REMOVE_PP"] = "Remover este esconderijo? |cffff9900 Todos itens que continuam dentro serão perdidos!",
	["DR_STASHES_REMOVED"] = "Esconderijo removido.",
	["DR_STASHES_RESYNC"] = "Re-sincronizando.",
	["DR_STASHES_SCAN"] = "Escanear por esconderijos de jogadores",
	["DR_STASHES_SCAN_MY"] = "Escanear pelos meus esconderijos",
	["DR_STASHES_SEARCH"] = "Procurar por esconderijos de |cff00ff00jogadores|r.",
	["DR_STASHES_SEARCH_ACTION"] = "Procurar por esconderijos de outros jogadores na área de 15 metros.",
	["DR_STASHES_SEARCH_TT"] = "Isto irá começar um scan por 3 seg, Fique parado!!",
	["DR_STASHES_SYNC"] = "Sincronizando...",
	["DR_STASHES_TOO_FAR"] = "Você está muito longe deste esconderijo.",
	["DR_STASHES_WITHIN"] = "|cff00ff00Seu|s esconderijos dentro de 15 metros",
	["DR_SYSTEM"] = "Sistema de soltar",
	["DR_SYSTEM_TT"] = "Soltar/procurar por itens e criar/acessar seus esconderijos. O sistema de soltar não funciona em masmorras/arenas/ou campos de batalha.",
	["EDITOR_BOTTOM"] = "Fundo",
	["EDITOR_CANCEL_TT"] = [=[Cancela todas mudanças em todo o objeto %s (Objeto raiz e internos).
|cffff9900mudanças não salvas serão perdidas!]=],
	["EDITOR_CONFIRM"] = "Confirmar",
	["EDITOR_HEIGHT"] = "Altura",
	["EDITOR_ICON"] = "Selecionar ícone",
	["EDITOR_ICON_SELECT"] = "Clique para selecionar um ícone",
	["EDITOR_ID_COPY"] = "Copiar ID",
	["EDITOR_ID_COPY_POPUP"] = "Você pode copiar a ID do objeto abaixo se você precisar em algum lugar.",
	["EDITOR_MAIN"] = "Principal",
	["EDITOR_MORE"] = "Mais",
	["EDITOR_NOTES"] = "Notas livres",
	["EDITOR_PREVIEW"] = "Prévia",
	["EDITOR_SAVE_TT"] = "Salve todas mudanças de todo o objeto %s (objeto raiz e todos os objetos internos) e incrementa automaticamente o número da versão.",
	["EDITOR_TOP"] = "Topo",
	["EDITOR_WARNINGS"] = "Existem %s avisos. |cffff9900%s|r Salvar mesmo assim?",
	["EDITOR_WIDTH"] = "Largura",
	["EFFECT_CAT_CAMERA"] = "Câmera",
	["EFFECT_CAT_CAMERA_LOAD"] = "Carregar câmera",
	["EFFECT_CAT_CAMERA_LOAD_TT"] = "Define a posição da câmera do jogador com base em uma posição salva anteriormente.",
	["EFFECT_CAT_CAMERA_SAVE"] = "Salvar câmera",
	["EFFECT_CAT_CAMERA_SAVE_TT"] = "Salva a posição atual da câmera do jogador em um dos 5 espaços disponíveis.",
	["EFFECT_CAT_CAMERA_SLOT"] = "Espaço número",
	["EFFECT_CAT_CAMERA_SLOT_TT"] = "O index de um dos endereços de espaços disponíveis, 1 de 5.",
	["EFFECT_CAT_CAMERA_ZOOM_DISTANCE"] = "Distância do zoom",
	["EFFECT_CAT_CAMERA_ZOOM_IN"] = "Aumentar zoom da câmera",
	["EFFECT_CAT_CAMERA_ZOOM_IN_TT"] = "Aumenta o zoom da câmera em uma distância especificada.",
	["EFFECT_CAT_CAMERA_ZOOM_OUT"] = "diminuir zoom da câmera",
	["EFFECT_CAT_CAMERA_ZOOM_OUT_TT"] = "Diminui o zoom da câmera por uma distância especificada.",
	["EFFECT_CAT_CAMPAIGN"] = "Campanha e missão",
	["EFFECT_CAT_SOUND"] = "Som e música",
	["EFFECT_CAT_SPEECH"] = "Discursos e emotes",
	["EFFECT_COOLDOWN_DURATION"] = "Duração do tempo de recarga",
	["EFFECT_COOLDOWN_DURATION_TT"] = "Duração do tempo de recarga, em segundos.",
	["EFFECT_DIALOG_ID"] = "ID da cutscene",
	["EFFECT_DIALOG_QUICK"] = "Cutscene rápida",
	["EFFECT_DIALOG_QUICK_TT"] = "Gera uma rápida cutscene com somente um passo. Ela irá automaticamente pegar o alvo do jogador como aquele que fala",
	["EFFECT_DIALOG_START"] = "Começar cutscene",
	["EFFECT_DIALOG_START_PREVIEW"] = "Começar cutscene %s.",
	["EFFECT_DIALOG_START_TT"] = "Começar a cutscene. Se a cutscene já está tocando , ela será interrompida e substituída por esta.",
	["EFFECT_DISMOUNT"] = "Dispensar montaria",
	["EFFECT_DISMOUNT_TT"] = "Desmontar o jogador de sua atual montaria.",
	["EFFECT_DISPET"] = "Dispensar pet de batalha",
	["EFFECT_DISPET_TT"] = "Dispensar o atual pet de batalha invocado.",
	["EFFECT_DO_EMOTE"] = "Fazer um emote",
	["EFFECT_DO_EMOTE_ANIMATED"] = "Animado",
	["EFFECT_DO_EMOTE_OTHER"] = "Outros",
	["EFFECT_DO_EMOTE_SPOKEN"] = "Falado",
	["EFFECT_DO_EMOTE_TT"] = "Fazer o jogador fazer uma animação de emote específica.",
	["EFFECT_DOC_CLOSE"] = "Fechar documento",
	["EFFECT_DOC_CLOSE_TT"] = "Fechar o atual documento aberto. não faça nada se não tem documento mostrado.",
	["EFFECT_DOC_DISPLAY"] = "Exibir documento",
	["EFFECT_DOC_DISPLAY_TT"] = "Exibir documento para o jogador. Se já há um documento sendo mostrado, será ser substituido.",
	["EFFECT_DOC_ID"] = "ID do documento",
	["EFFECT_DOC_ID_TT"] = "O documento a ser mostrado. |cffffff00 por favor entre com a id completa do documento (ID familiar e ID interno). |cff00ff00Dica: Copie/cole a ID para ter certeza de não errar tipos.",
	["EFFECT_ITEM_ADD"] = "Adicionar item",
	["EFFECT_ITEM_ADD_CRAFTED"] = "Criado",
	["EFFECT_ITEM_ADD_CRAFTED_TT"] = "Quando marcado,e se os itens adicionados sao criados( que tem a marcação de criado  na area de atributos), irá mostrar \"Criado por XXX\" na caixa de ferramentas do item sendo XXX o nome do jogador que criou.",
	["EFFECT_ITEM_ADD_ID"] = "ID do Item"
};

TRP3_API.loc:GetLocale("ptBR"):AddTexts(L);
