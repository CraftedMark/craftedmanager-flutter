import 'package:crafted_manager/Models/Invoice_model.dart';
import 'package:crafted_manager/assets/ui.dart';
import 'package:crafted_manager/widgets/divider.dart';
import 'package:crafted_manager/widgets/edit_button.dart';
import 'package:crafted_manager/widgets/tile.dart';
import 'package:flutter/material.dart';

class InvoicesList extends StatefulWidget {
  final List<Invoice> invoices;

  const InvoicesList({
    Key? key,
    required this.invoices,
  }) : super(key: key);

  @override
  _InvoicesListState createState() => _InvoicesListState();
}

class _InvoicesListState extends State<InvoicesList> {
  bool _isEditing = false;

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Invoices',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      body: ListView.builder(
        itemCount: widget.invoices.length,
        itemBuilder: (BuildContext context, int index) {
          return InvoiceTile(
            invoice: widget.invoices[index],
            isEditing: _isEditing,
            onEdit: _toggleEditing,
          );
        },
      ),
    );
  }
}

class InvoiceTile extends StatelessWidget {
  final Invoice invoice;
  final bool isEditing;
  final VoidCallback onEdit;

  const InvoiceTile({
    Key? key,
    required this.invoice,
    required this.isEditing,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tile(
      child: Container(
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text('Invoice Number: ${invoice.invoiceNumber}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: UIConstants.WHITE)),
            Text('Invoice Date: ${invoice.invoiceDate}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: UIConstants.WHITE)),
            Text('Invoice Amount: \$${invoice.totalAmount}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: UIConstants.WHITE)),
            const DividerCustom(),
            EditButton(onPressed: onEdit),
          ],
        ),
      ),
    );
  }
}
