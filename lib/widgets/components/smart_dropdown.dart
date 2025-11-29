import 'package:flutter/material.dart';

// 1. КОНТРОЛЛЕР (Как TextEditingController, только для выбора)
class SelectionController<T> extends ValueNotifier<T?> {
  SelectionController({T? initialValue}) : super(initialValue);

  // Удобный геттер/сеттер
  T? get selectedItem => value;
  set selectedItem(T? newItem) => value = newItem;
}

// 2. УМНЫЙ ДРОПДАУН (Сам слушает контроллер, не нужен setState в родителе)
// lib/ui_kit.dart

class SmartDropdown<T> extends StatelessWidget {
  final SelectionController<T> controller;
  final List<DropdownMenuItem<T>> items;
  final String label;
  final String? hint;
  // Добавляем коллбэк для побочных действий
  final ValueChanged<T?>? onChanged; 

  const SmartDropdown({
    super.key,
    required this.controller,
    required this.items,
    required this.label,
    this.hint,
    this.onChanged, // <---
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T?>(
      valueListenable: controller,
      builder: (context, currentValue, child) {
        
        // Безопасная проверка (из прошлого шага)
        bool valueExists = currentValue != null && items.any((item) => item.value == currentValue);
        T? effectiveValue = valueExists ? currentValue : null;

        return DropdownButtonFormField<T>(
          // ! ИСПРАВЛЕНИЕ: value deprecated. Используем initialValue + Key для реактивности.
          // Key заставляет Flutter пересоздать виджет, если значение изменилось, 
          // так как FormField игнорирует изменения initialValue после инициализации.
          key: ValueKey(effectiveValue),
          initialValue: effectiveValue, 
          items: items,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            suffixIcon: effectiveValue != null
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      controller.selectedItem = null;
                      // Не забываем вызвать коллбэк при очистке
                      if (onChanged != null) onChanged!(null); 
                    },
                  )
                : null,
          ),
          onChanged: (newValue) {
            // 1. Обновляем свой контроллер
            controller.selectedItem = newValue;
            // 2. Если есть внешняя логика - вызываем её
            if (onChanged != null) onChanged!(newValue);
          },
        );
      },
    );
  }
}