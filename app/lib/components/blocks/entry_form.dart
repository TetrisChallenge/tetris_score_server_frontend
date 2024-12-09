import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:provider/provider.dart';

import '../../model/form_model.dart' as FormModel;
import '../../model/score_evaluation_message.pb.dart';
import '../../view_model/providers.dart';
import '../../view_model/form_view_model.dart' as FormViewModel;

class EntryForm extends HookConsumerWidget {
  final String _competition;
  EntryForm(this._competition);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var _screenSize = MediaQuery.of(context).size;
    final _userNameFormController = useTextEditingController(text: "");
    final _repositoryURLFormController = useTextEditingController(text: "https://github.com/seigot/tetris");
    final _branchFormController = useTextEditingController(text: "master");
    final _levelFormController = useTextEditingController(text: "1");
    final _predictWeightPathController = useTextEditingController(text: "");
    final _trialNumberController = useTextEditingController(text: "1");
    final _gameModeController = useTextEditingController(text: "default");
    final _gameTimeController = useTextEditingController(text: "2");
    final _competitionController = useTextEditingController(text: _competition);
    final _formCardHeight = _screenSize.height * 0.11;
    final _formCardWidth = _screenSize.width * 0.5;
    final _state = ref.watch(formStateNotifierProvider);

    return Form(
      key: _formKey,
      child: Container(
        width: _screenSize.width * 0.7,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: SizedBox(
                    width: _formCardWidth,
                    height: _formCardHeight,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'program name',
                      ),
                      controller: _userNameFormController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: SizedBox(
                    width: _formCardWidth,
                    height: _formCardHeight,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'github repository URL',
                      ),
                      controller: _repositoryURLFormController,
                      validator: (String? value) {
                        String? res = ref.read(formStateNotifierProvider.notifier).checkRepositoryURLPattern(value);
                        return res;
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: SizedBox(
                    width: _formCardWidth,
                    height: _formCardHeight,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'branch name',
                      ),
                      controller: _branchFormController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: SizedBox(
                    width: _formCardWidth,
                    height: _formCardHeight,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'game level',
                      ),
                      controller: _levelFormController,
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        List levels = ["1", "2", "3", "4"];
                        if (!levels.contains(value)) {
                          return 'Value must be in ${levels}';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: SizedBox(
                    width: _formCardWidth,
                    height: _formCardHeight,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'game mode ["default", "predict", "predict_sample", "predict_sample2", "art"]',
                      ),
                      controller: _gameModeController,
                      validator: (String? value) {
                        List game_modes = ["default", "predict", "predict_sample", "predict_sample2", "art"];
                        if (!game_modes.contains(value)) {
                          return 'must be in ${game_modes}';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: SizedBox(
                    width: _formCardWidth,
                    height: _formCardHeight,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'predict weight path',
                      ),
                      controller: _predictWeightPathController,
                    ),
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: Center(
                  child: SizedBox(
                    width: _formCardWidth,
                    height: _formCardHeight,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'competition(fixed)',
                      ),
                      controller: _competitionController,
                      enabled: false,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ((){
                  if (_state is FormViewModel.FormInitial){
                    return ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {// validate form data when button pressed
                          ref.read(formStateNotifierProvider.notifier).setFormValidationErrorState();
                          return;
                        }
                        ref.read(formStateNotifierProvider.notifier).submitEntryMessage(
                          FormModel.FormModel(
                            _userNameFormController.text,
                            _repositoryURLFormController.text,
                            _branchFormController.text,
                            1000,
                            int.parse(_levelFormController.text),
                            _gameModeController.text,
                            int.parse(_gameTimeController.text),
                            185,
                            _predictWeightPathController.text,
                            int.parse(_trialNumberController.text),
                            [], // invalid random_seed field
                            _competitionController.text,
                          )
                        );
                      },
                      child: const Text("Submit"),
                    );
                  } else if (_state is FormViewModel.FormSubmitting){
                    return CircularProgressIndicator();
                  } else if (_state is FormViewModel.FormSubmitted){
                    return Text("form successfully submitted");
                  } else if (_state is FormViewModel.FormError){
                    return Text(_state.message);
                  } else {
                  return Text("unexpected error occured\n${_state}");
                  }
                })(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0),
                child: ((){
                  if (_state is FormViewModel.FormError || _state is FormViewModel.FormSubmitted){
                    return ElevatedButton(
                      onPressed: (){
                        ref.read(formStateNotifierProvider.notifier).initializeState();
                      },
                      child: const Text("OK"),
                    );
                  } 
                })(),
              )
            ],
          ),
        ),
      )
    );
  }
}
