import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_app/models/invoice.dart';

class InvoicesState {
  final List<Invoice> invoices;

  InvoicesState(this.invoices);
}

class InvoicesCubit extends Cubit<InvoicesState> {
  InvoicesCubit() : super(InvoicesState([]));

  void addInvoice(String clientId, String addressId) {
    final newInvoice = Invoice(
      DateTime.now().millisecondsSinceEpoch.toString(),
      clientId,
      addressId,
    );
    final newList = List<Invoice>.from(state.invoices)..add(newInvoice);
    emit(InvoicesState(newList));
  }

  Invoice? findById(String id) {
    try {
      return state.invoices.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}
