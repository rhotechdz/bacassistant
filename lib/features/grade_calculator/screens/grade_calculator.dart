import 'dart:convert';

import 'package:bacassistant/features/grade_calculator/models/score.dart';
import 'package:bacassistant/features/grade_calculator/models/subjects.dart';
import 'package:bacassistant/utils/initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final subjects = Subjects();

class GradeCalculatorPage extends StatefulWidget {
  const GradeCalculatorPage({super.key});

  @override
  State<GradeCalculatorPage> createState() => _GradeCalculatorPageState();
}

class _GradeCalculatorPageState extends State<GradeCalculatorPage> {

  void _toggle(String key) {
    setState(() {
      subjects.update(key);
    });
  }

  @override
  void initState() {
    prefs.remove('GPA_records');
    super.initState();
  }

  Widget showRecordsList() {
    final String recordsList = prefs.getString('GPA_records')!;
    final Map<String, dynamic> recordsMap = jsonDecode(recordsList);
    
    return Column(
      children: [
        const Text(
          'السجلات السابقة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (var entry in recordsMap.entries)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: ListTile(
                    onTap: () {
                      showDialog(context: context, builder: (builder) {
                        return AlertDialog(
                          title: const Text('تفاصيل السجل'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('المعدل: ${recordsMap[entry.key]['GPA'].toStringAsFixed(2)}'),
                              Text('المادة: ${recordsMap[entry.key]['subject']}'),
                              for (var pair in recordsMap[entry.key].entries)
                                if (pair.value is Map)
                                  Text('${pair.key}: ${pair.value['points']} (عامل: ${pair.value['factor']})'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('إغلاق'),
                            ),
                          ],
                        );
                      });
                    },
                    subtitle: Text(
                      DateTime.fromMillisecondsSinceEpoch(int.parse(entry.key))
                        .toLocal()
                        .toString()
                        .split(' ')
                        .first,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12),
                    ),
                    title: Text(
                      recordsMap[entry.key]['GPA'].toStringAsFixed(2),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 26
                      ),
                    ),
                    leading: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_rounded),
                    ),
                  ),
                )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Toggle List"),
        actions: [
          prefs.getString('GPA_records') != null
          ? IconButton(
            onPressed: () => {
              showModalBottomSheet(
                context: context,
                builder: (builder) {
                  return SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.45,
                    child: showRecordsList(),
                  );
                }
              )
            },
            icon: const Icon(Icons.history_rounded)
          )
          : const SizedBox()
        ],
      ),
      body: ListView(
        children: [
          ...List.generate(subjects.length, (index) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(subjects.values[index].toString()),
                    Text(subjects.keys[index]),
                  ],
                ),
              ],
            );
          }),
          Divider(),
          ...subjects.optional.entries.map((entry) {
            final isEnabled = entry.value[1];
            return InkWell(
              onTap: () => _toggle(entry.key),
              child: Container(
                color: isEnabled ? Colors.white : Colors.grey[300],
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      entry.value[0].toString(),
                      style: TextStyle(
                        color: isEnabled ? Colors.black : Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.key,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: isEnabled ? Colors.black : Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Icon(
                      isEnabled ? Icons.check_box : Icons.check_box_outline_blank,
                      color: isEnabled ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 8)
                  ],
                ),
              ),
            );
          }),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              subjects.unify();
              return Dialog(
                insetPadding: EdgeInsets.symmetric(horizontal: 60),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  //margin: EdgeInsets.all(50),
                  child: DialogContent(),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}

class DialogContent extends StatefulWidget {
  const DialogContent({super.key});

  @override
  State<DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GPAModel gpaModel = GPAModel();

  String? _errorText;
  int currentIndex = 0;
  List<double> points = [];


  void _validateInput(String value) {
    if (value.isEmpty) {
      setState(() => _errorText = 'النقطة لا تكون فارغة');
      _focusNode.requestFocus();
      return;
    } else if (double.tryParse(value) == null || double.parse(value) > 20) {
      setState(() => _errorText = 'النقطة لا تتجاوز 20');
      _focusNode.requestFocus();
      return;
    }

    if (currentIndex + 1 < subjects.unified.length) {
      setState(() {
        final key = subjects.unified.keys.toList()[currentIndex];
        _errorText = null;
        gpaModel.scoreMap[key] = {
          'points': double.parse(_controller.value.text),
          'factor': subjects.unified[key]
        };
        currentIndex += 1;
        _controller.clear();
      });
      // 🔑 keep focus alive
      _focusNode.requestFocus();
    } else {
      gpaModel.scoreMap['GPA'] = gpaModel.calculateAverage();
      print(gpaModel.scoreMap.toString());
      gpaModel.saveResult();
        showModalBottomSheet(
      context: context,
      builder: (builder) {
        return SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            textBaseline: TextBaseline.ideographic,
            children: [
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0)
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    gpaModel.calculateAverage().toStringAsFixed(2),
                    style: Theme.of(context).textTheme.displayLarge!
                      .copyWith(
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Noto Sans Display'
                      ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                textBaseline: TextBaseline.ideographic,
                children: [
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                        },
                        iconSize: 50,
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.only(top: 8, bottom: 8, left: 9, right: 12)
                          ),
                        ),
                        icon: const Icon(Icons.share_rounded)
                      ),
                      const SizedBox(height: 10),
                      const Text('مشاركة'),
                    ],
                  ),
                  Column(
                    children: [
                      IconButton.filled(
                        onPressed: () {
                        },
                        iconSize: 50,
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 8, horizontal: 6)
                          ),
                        ),
                        icon: const Icon(Icons.replay_rounded)
                      ),
                      const SizedBox(height: 10),
                      const Text('اعادة')
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
      
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 🔑 Title updates but TextField stays mounted
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            subjects.unified.keys.toList()[currentIndex],
            key: ValueKey(currentIndex), // only text swaps
            textAlign: TextAlign.center,
            style: textStyle,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          focusNode: _focusNode,
          controller: _controller,
          autofocus: true,
          textAlign: TextAlign.center,
          enableInteractiveSelection: false,
          keyboardType: TextInputType.number,
          style: textStyle,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
          ],
          onSubmitted: _validateInput,
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _errorText == null
            ? const SizedBox.shrink()
            : Text(
              _errorText!,
              key: ValueKey(_errorText),
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
        ),
      ],
    );
  }
}
