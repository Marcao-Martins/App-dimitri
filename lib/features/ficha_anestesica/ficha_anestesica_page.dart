import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ficha_provider.dart';
import 'widgets/paciente_form_widget.dart';
import 'widgets/dynamic_table.dart';
import 'widgets/monitoring_table.dart';
import 'widgets/charts_widget.dart';
import 'pdf/pdf_service.dart';

class FichaAnestesicaPage extends StatefulWidget {
  final bool showAppBar;

  const FichaAnestesicaPage({super.key, this.showAppBar = true});

  @override
  State<FichaAnestesicaPage> createState() => _FichaAnestesicaPageState();
}

class _FichaAnestesicaPageState extends State<FichaAnestesicaPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      appBar: widget.showAppBar
          ? AppBar(
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
                        Tab(text: 'Gráficos'),
                      ],
                    )
                  : null,
            )
          : null,
      body: provider.current == null
          ? _buildWelcomeScreen(context, provider)
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMedicationsTab(context, provider),
                _buildMonitoringTab(context, provider),
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
          ),
          const SizedBox(height: 12),

          // Antimicrobianos
          DynamicTable(
            title: 'Antimicrobianos',
            items: provider.current!.antimicrobianos,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.antimicrobianos, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.antimicrobianos, i),
          ),
          const SizedBox(height: 12),

          // Indução
          DynamicTable(
            title: 'Indução Anestésica',
            items: provider.current!.inducao,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.inducao, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.inducao, i),
          ),
          const SizedBox(height: 12),

          // Manutenção
          DynamicTable(
            title: 'Manutenção Anestésica',
            items: provider.current!.manutencao,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.manutencao, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.manutencao, i),
          ),
          const SizedBox(height: 12),

          // Locorregional
          DynamicTable(
            title: 'Anestesia Locorregional',
            items: provider.current!.locorregional,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.locorregional, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.locorregional, i),
          ),
          const SizedBox(height: 12),

          // Analgesia pós-operatória
          DynamicTable(
            title: 'Analgesia Pós-operatória',
            items: provider.current!.analgesiaPosOperatoria,
            onAdd: (med) => provider.addMedicacaoTo(provider.current!.analgesiaPosOperatoria, med),
            onRemove: (i) => provider.removeMedicacaoFrom(provider.current!.analgesiaPosOperatoria, i),
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

  Widget _buildChartsTab(BuildContext context, FichaProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: ChartsWidget(data: provider.current!.parametros),
    );
  }
}
