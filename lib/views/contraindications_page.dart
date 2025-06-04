import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/contraindications_viewmodel.dart';

class ContraindicationsPage extends StatelessWidget {
  const ContraindicationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContraindicationsViewModel(),
      child: Consumer<ContraindicationsViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: const Color(0xff211111),
            appBar: AppBar(
              backgroundColor: const Color(0xff211111),
              elevation: 0,
              title: const Text(
                'Ограничения здоровья',
                style: TextStyle(color: Colors.white),
              ),
              iconTheme: const IconThemeData(color: Colors.white),
              actions: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: vm.isLoading ? null : () => vm.saveSelection(context),
                ),
              ],
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : (vm.error != null
                    ? Center(
                        child: Text(
                          vm.error!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: vm.available.length,
                        itemBuilder: (context, groupIndex) {
                          final group = vm.available[groupIndex];
                          return _buildGroup(context, group, vm);
                        },
                      )),
          );
        },
      ),
    );
  }

  Widget _buildGroup(BuildContext context, dynamic group, ContraindicationsViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: const Color(0xff331919),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        collapsedIconColor: Colors.white,
        iconColor: Colors.white,
        title: Text(
          group['groupName'],
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Lexend-Bold',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        children: (group['items'] as List).map<Widget>((item) {
          final code = item['code'] as String;
          return CheckboxListTile(
            activeColor: const Color(0xFFE51919),
            title: Text(
              item['title'] as String,
              style: const TextStyle(
                color: Colors.white70,
                fontFamily: 'Lexend-Regular',
                fontWeight: FontWeight.w400,
              ),
            ),
            value: vm.selected.contains(code),
            onChanged: (val) => vm.onCheckboxChanged(context, val, code),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          );
        }).toList(),
      ),
    );
  }
}