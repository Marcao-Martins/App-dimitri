import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ficha_provider.dart';
import 'widgets/paciente_form_widget.dart';
import 'widgets/dynamic_table.dart';
import 'widgets/monitoring_table.dart';
import 'widgets/charts_widget.dart';
import 'widgets/procedure_timer_widget.dart';
import 'widgets/monitoring_alarm_widget.dart';
import 'widgets/image_attachment_widget.dart';
import 'widgets/airway_management.dart';
import 'pdf/pdf_service.dart';

class FichaAnestesicaPage extends StatefulWidget {
  const FichaAnestesicaPage({super.key});

  @override
  State<FichaAnestesicaPage> createState() => _FichaAnestesicaPageState();
}

class _FichaAnestesicaPageState extends State<FichaAnestesicaPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FichaProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ficha Anestésica'),
        actions: [
          if (provider.current != null) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                try {
                  await provider.saveCurrent();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ficha salva com sucesso!')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao salvar: $e')),
                    );
                  }
                }
              },
              tooltip: 'Salvar Ficha',
            ),
            IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () async {
                try {
                  await PdfService.printFicha(provider.current!);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erro ao gerar PDF: $e')),
                    );
                  }
                }
              },
              tooltip: 'Exportar PDF',
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                provider.clearCurrent();
              },
              tooltip: 'Fechar Ficha',
            ),
          ],
        ],
        bottom: provider.current != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Paciente & Medicações'),
                  Tab(text: 'Monitorização'),
                  Tab(text: 'Intercorrências'),
                  Tab(text: 'Gráficos'),
                ],
              )
            : null,
      ),
      body: provider.current == null
          ? _buildWelcomeScreen(context, provider)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMedicationsTab(context, provider),
                _buildMonitoringTab(context, provider),
                _buildIntercorrenciasTab(context, provider),
                _buildChartsTab(context, provider),
              ],
            ),
      floatingActionButton: provider.current == null
          ? FloatingActionButton.extended(
              onPressed: () => _showCreateFichaDialog(context, provider),
              icon: const Icon(Icons.add),
              label: const Text('Nova Ficha'),
            )
          : null,
    );
  }

  Widget _buildWelcomeScreen(BuildContext context, FichaProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Crie uma nova ficha ou carregue uma existente',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (provider.fichas.isNotEmpty) ...[
              const Text('Fichas Salvas:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...provider.fichas.take(5).map((ficha) {
                final id = ficha.paciente.data?.millisecondsSinceEpoch.toString() ?? 
                           ficha.paciente.nome.hashCode.toString();
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: Text(ficha.paciente.nome),
                    subtitle: Text('${ficha.paciente.especie ?? ''} - ${ficha.paciente.procedimento ?? ''}'),
                    onTap: () => provider.load(ficha, id),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  void _showCreateFichaDialog(BuildContext context, FichaProvider provider) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: PacienteFormWidget(
              onSave: (paciente) {
                provider.createNew(paciente);
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationsTab(BuildContext context, FichaProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cronômetro e Alarme de Monitorização
          Row(
            children: [
              const Expanded(child: ProcedureTimerWidget()),
              const SizedBox(width: 8),
              const MonitoringAlarmWidget(),
            ],
          ),
          const SizedBox(height: 12),
          
          // Informações do Paciente (resumo)
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.current!.paciente.nome,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.current!.paciente.especie ?? ''} • ${provider.current!.paciente.peso ?? '?'} kg • ASA ${provider.current!.paciente.asa ?? '?'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (provider.current!.paciente.procedimento != null)
                    Text('Procedimento: ${provider.current!.paciente.procedimento}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Medicação Pré-anestésica
          DynamicTable(
            title: 'Medicação Pré-anestésica',
            items: provider.current!.preAnestesica,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.preAnestesica, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.preAnestesica, i),
            onUpdate: (i, med) => provider.updateMedicacaoIn(provider.current!.preAnestesica, i, med),
          ),
          const SizedBox(height: 12),

          // Antimicrobianos
          DynamicTable(
            title: 'Antimicrobianos',
            items: provider.current!.antimicrobianos,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.antimicrobianos, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.antimicrobianos, i),
            onUpdate: (i, med) => provider.updateMedicacaoIn(provider.current!.antimicrobianos, i, med),
          ),
          const SizedBox(height: 12),

          // Indução
          DynamicTable(
            title: 'Indução Anestésica',
            items: provider.current!.inducao,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.inducao, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.inducao, i),
            onUpdate: (i, med) => provider.updateMedicacaoIn(provider.current!.inducao, i, med),
          ),
          const SizedBox(height: 12),

          // Manutenção
          DynamicTable(
            title: 'Manutenção Anestésica',
            items: provider.current!.manutencao,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.manutencao, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.manutencao, i),
            onUpdate: (i, med) => provider.updateMedicacaoIn(provider.current!.manutencao, i, med),
          ),
          const SizedBox(height: 12),

          // Locorregional
          DynamicTable(
            title: 'Anestesia Locorregional',
            items: provider.current!.locorregional,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.locorregional, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.locorregional, i),
            showTecnicaField: true,
            onUpdate: (i, med) => provider.updateMedicacaoIn(provider.current!.locorregional, i, med),
          ),
          const SizedBox(height: 12),

          // Analgesia pós-operatória
          DynamicTable(
            title: 'Analgesia Pós-operatória',
            items: provider.current!.analgesiaPosOperatoria,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.analgesiaPosOperatoria, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.analgesiaPosOperatoria, i),
            onUpdate: (i, med) => provider.updateMedicacaoIn(provider.current!.analgesiaPosOperatoria, i, med),
          ),
          const SizedBox(height: 16),

          // Manejo de vias aéreas
          const AirwayManagement(),
          const SizedBox(height: 16),

          // Seção de Imagens
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ImageAttachmentWidget(
                imagePaths: provider.currentImagePaths,
                onImageAdded: (path) => provider.addImage(path),
                onImageRemoved: (path) => provider.removeImage(path),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonitoringTab(BuildContext context, FichaProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Referência rápida ao tempo de procedimento
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer.withAlpha((0.3 * 255).round()),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 20,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.55),
                        child: Text(
                          'Tempo de Procedimento: ${_formatTimerDuration(provider.current!.procedureTimeSeconds)}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.9),
                        child: Text(
                          '(Veja na aba Paciente & Medicações para controlar)',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSecondaryContainer.withAlpha((0.7 * 255).round()),
                            fontStyle: FontStyle.italic,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          MonitoringTable(
            items: provider.current!.parametros,
            onAddTime: (param) => provider.addParametro(param),
            onRemoveTime: (i) => provider.removeParametroAt(i),
            onUpdate: (i, param) => provider.updateParametro(i, param),
          ),
        ],
      ),
    );
  }

  String _formatTimerDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$secs';
  }

  Widget _buildIntercorrenciasTab(BuildContext context, FichaProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Seção de Intercorrências
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Intercorrências',
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // botão responsivo para evitar overflow em telas pequenas
                      LayoutBuilder(builder: (context, constraints) {
                        final num computed = constraints.maxWidth.isFinite
                            ? (constraints.maxWidth * 0.35).clamp(80, 140)
                            : 140;
                        final double btnW = computed.toDouble();
                        return SizedBox(
                          width: btnW,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddIntercorrenciaDialog(context, provider),
                            icon: const Icon(Icons.add, size: 16),
                            label: FittedBox(fit: BoxFit.scaleDown, child: const Text('Adicionar')),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (provider.current!.intercorrencias.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Nenhuma intercorrência registrada'),
                      ),
                    )
                  else
                    ...provider.current!.intercorrencias.asMap().entries.map((entry) {
                      final index = entry.key;
                      final inter = entry.value;
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        color: inter.gravidade == 'grave'
                            ? (isDark ? Colors.red.shade900.withAlpha((0.3 * 255).round()) : Colors.red.shade50)
                            : inter.gravidade == 'moderada'
                                ? (isDark ? Colors.orange.shade900.withAlpha((0.3 * 255).round()) : Colors.orange.shade50)
                                : (isDark ? Colors.yellow.shade900.withAlpha((0.3 * 255).round()) : Colors.yellow.shade50),
                        child: ListTile(
                          leading: Icon(
                            Icons.warning_amber,
                            color: inter.gravidade == 'grave'
                                ? (isDark ? Colors.red.shade300 : Colors.red)
                                : inter.gravidade == 'moderada'
                                    ? (isDark ? Colors.orange.shade300 : Colors.orange)
                                    : (isDark ? Colors.yellow.shade300 : Colors.amber),
                          ),
                          title: Text(inter.descricao),
                          subtitle: Text(
                            '${_formatDateTime(inter.momento)} - Gravidade: ${inter.gravidade}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => provider.removeIntercorrencia(index),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Seção de Fármacos Intraoperatórios
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Fármacos Intraoperatórios',
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      LayoutBuilder(builder: (context, constraints) {
                        final num computed = constraints.maxWidth.isFinite
                            ? (constraints.maxWidth * 0.35).clamp(80, 140)
                            : 140;
                        final double btnW = computed.toDouble();
                        return SizedBox(
                          width: btnW,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddFarmacoIntraDialog(context, provider),
                            icon: const Icon(Icons.add, size: 16),
                            label: FittedBox(fit: BoxFit.scaleDown, child: const Text('Adicionar')),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 13),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (provider.current!.farmacosIntraoperatorios.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Nenhum fármaco intraoperatório registrado'),
                      ),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Hora')),
                          DataColumn(label: Text('Fármaco')),
                          DataColumn(label: Text('Dose')),
                          DataColumn(label: Text('Via')),
                          DataColumn(label: Text('Ações')),
                        ],
                        rows: provider.current!.farmacosIntraoperatorios
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final farmaco = entry.value;
                          return DataRow(cells: [
                            DataCell(Text(_formatTime(farmaco.hora))),
                            DataCell(Text(farmaco.nome)),
                            DataCell(Text('${farmaco.dose} ${farmaco.unidade}')),
                            DataCell(Text(farmaco.via)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => provider.removeFarmacoIntraoperatorio(index),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _showAddIntercorrenciaDialog(BuildContext context, FichaProvider provider) async {
    final descricaoController = TextEditingController();
    String gravidade = 'leve';
    DateTime selectedTime = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar Intercorrência'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição *',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: gravidade,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Gravidade',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'leve', child: Text('Leve')),
                    DropdownMenuItem(value: 'moderada', child: Text('Moderada')),
                    DropdownMenuItem(value: 'grave', child: Text('Grave')),
                  ],
                  onChanged: (value) {
                    setState(() => gravidade = value ?? 'leve');
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text(_formatDateTime(selectedTime)),
                  trailing: const Icon(Icons.schedule),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedTime),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = DateTime(
                          selectedTime.year,
                          selectedTime.month,
                          selectedTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (descricaoController.text.isNotEmpty) {
                  provider.addIntercorrencia(
                    descricaoController.text,
                    selectedTime,
                    gravidade,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddFarmacoIntraDialog(BuildContext context, FichaProvider provider) async {
    final nomeController = TextEditingController();
    final doseController = TextEditingController();
  String unidade = 'mg/kg';
    String via = 'IV';
    DateTime selectedTime = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Adicionar Fármaco Intraoperatório'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do Fármaco *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: doseController,
                        decoration: const InputDecoration(
                          labelText: 'Dose *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        initialValue: unidade,
                        decoration: const InputDecoration(
                          labelText: 'Unidade',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'mg/kg', child: Text('mg/kg')),
                          DropdownMenuItem(value: 'ml/kg', child: Text('ml/kg')),
                          DropdownMenuItem(value: 'mcg/kg', child: Text('mcg/kg')),
                          DropdownMenuItem(value: 'ml', child: Text('ml')),
                        ],
                        onChanged: (value) {
                          setState(() => unidade = value ?? 'mg/kg');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: via,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Via de Administração',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'IV', child: Text('Intravenosa (IV)')),
                    DropdownMenuItem(value: 'IM', child: Text('Intramuscular (IM)')),
                    DropdownMenuItem(value: 'SC', child: Text('Subcutânea (SC)')),
                    DropdownMenuItem(value: 'VO', child: Text('Via Oral (VO)')),
                    DropdownMenuItem(value: 'Inalatória', child: Text('Inalatória')),
                  ],
                  onChanged: (value) {
                    setState(() => via = value ?? 'IV');
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Hora'),
                  subtitle: Text(_formatDateTime(selectedTime)),
                  trailing: const Icon(Icons.schedule),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(selectedTime),
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = DateTime(
                          selectedTime.year,
                          selectedTime.month,
                          selectedTime.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nomeController.text.isNotEmpty && doseController.text.isNotEmpty) {
                  final dose = double.tryParse(doseController.text.replaceAll(',', '.'));
                  if (dose != null && dose > 0) {
                    provider.addFarmacoIntraoperatorio(
                      nomeController.text,
                      dose,
                      unidade,
                      via,
                      selectedTime,
                    );
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsTab(BuildContext context, FichaProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: ChartsWidget(data: provider.current!.parametros),
    );
  }
}
