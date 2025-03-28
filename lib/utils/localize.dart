const Map<String, String> localize = {
  'appTitle': 'Expense',
  'expenseListTitle': 'Expense List',
  'form_label_amount': 'Amount',
  'form_label_comments': 'Comments',
  'form_label_category': 'Category',
  'form_button_add': 'Add Expense',
  'form_button_update': 'Update Expense',
  'form_error_amount_empty': 'Please enter amount',
  'form_error_amount_invalid': 'Please enter valid amount',
  'form_error_comments_empty': 'Please enter comments',
  'form_error_category_empty': 'Please select a category',
  'delete_confirmation': 'Are you sure you want to delete this expense?',
  'delete_confirmation_cancel': 'Cancel',
  'delete_confirmation_yes': 'Yes',
  'something_went_wrong': 'Something went wrong',
  'no_expense_found': 'No expense found',
  'expense_added': 'Expense added...🎉',
  'expense_updated': 'Expense updated...🎉',
  'expense_deleted': 'Expense deleted...🎉',
};
String getLocalizedString(String key, {String fallback = ''}) {
  return localize[key] ?? fallback;
}
