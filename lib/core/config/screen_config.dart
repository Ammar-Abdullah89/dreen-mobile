import 'package:flutter/material.dart';

class FieldDef {
  final String name;
  final String label;
  final IconData icon;
  final String type;
  final bool showInList;
  final bool showInDetail;

  const FieldDef({
    required this.name,
    required this.label,
    this.icon = Icons.text_fields,
    this.type = 'char',
    this.showInList = false,
    this.showInDetail = true,
  });
}

class SectionDef {
  final String title;
  final IconData icon;
  final List<FieldDef> fields;

  const SectionDef({
    required this.title,
    required this.icon,
    required this.fields,
  });
}

class ActionDef {
  final String label;
  final IconData icon;
  final String type;  // 'phone' | 'email' | 'map' | 'url' | 'sms'
  final String field;

  const ActionDef({
    required this.label,
    required this.icon,
    required this.type,
    required this.field,
  });
}

class ScreenConfig {
  final String model;
  final String title;
  final IconData icon;
  final List<String> listFields;
  final List<SectionDef> sections;
  final List<ActionDef> actions;
  final Color color;

  const ScreenConfig({
    required this.model,
    required this.title,
    required this.icon,
    required this.listFields,
    this.sections = const [],
    this.actions = const [],
    this.color = Colors.blue,
  });

  static const contacts = ScreenConfig(
    model: 'res.partner',
    title: 'Contacts',
    icon: Icons.contacts_outlined,
    color: Colors.blue,
    listFields: ['email', 'phone', 'company_name'],
    sections: [
      SectionDef(title: 'Contact Info', icon: Icons.contact_mail, fields: [
        FieldDef(name: 'email', label: 'Email', icon: Icons.email_outlined, type: 'email'),
        FieldDef(name: 'phone', label: 'Phone', icon: Icons.phone_outlined, type: 'phone'),
        FieldDef(name: 'mobile', label: 'Mobile', icon: Icons.smartphone_outlined, type: 'phone'),
        FieldDef(name: 'company_name', label: 'Company', icon: Icons.business_outlined),
        FieldDef(name: 'website', label: 'Website', icon: Icons.language_outlined, type: 'url'),
      ]),
      SectionDef(title: 'Address', icon: Icons.location_on_outlined, fields: [
        FieldDef(name: 'street', label: 'Street', icon: Icons.map_outlined),
        FieldDef(name: 'city', label: 'City', icon: Icons.location_city),
        FieldDef(name: 'state_id', label: 'State', icon: Icons.map_outlined),
        FieldDef(name: 'zip', label: 'ZIP', icon: Icons.map_outlined),
        FieldDef(name: 'country_id', label: 'Country', icon: Icons.flag_outlined),
      ]),
    ],
    actions: [
      ActionDef(label: 'Call', icon: Icons.phone, type: 'phone', field: 'phone'),
      ActionDef(label: 'Email', icon: Icons.email, type: 'email', field: 'email'),
      ActionDef(label: 'Map', icon: Icons.map, type: 'map', field: ''),
    ],
  );

  static const employees = ScreenConfig(
    model: 'hr.employee',
    title: 'Employees',
    icon: Icons.people_outline,
    color: Colors.teal,
    listFields: ['job_id', 'department_id', 'work_email'],
    sections: [
      SectionDef(title: 'Contact', icon: Icons.contact_mail, fields: [
        FieldDef(name: 'work_email', label: 'Email', icon: Icons.email_outlined, type: 'email'),
        FieldDef(name: 'work_phone', label: 'Phone', icon: Icons.phone_outlined, type: 'phone'),
        FieldDef(name: 'mobile_phone', label: 'Mobile', icon: Icons.smartphone_outlined, type: 'phone'),
      ]),
      SectionDef(title: 'Job Info', icon: Icons.work_outlined, fields: [
        FieldDef(name: 'job_id', label: 'Job Title', icon: Icons.badge_outlined),
        FieldDef(name: 'department_id', label: 'Department', icon: Icons.account_tree_outlined),
        FieldDef(name: 'parent_id', label: 'Manager', icon: Icons.supervisor_account_outlined),
        FieldDef(name: 'coach_id', label: 'Coach', icon: Icons.psychology_outlined),
      ]),
    ],
    actions: [
      ActionDef(label: 'Call', icon: Icons.phone, type: 'phone', field: 'work_phone'),
      ActionDef(label: 'Email', icon: Icons.email, type: 'email', field: 'work_email'),
    ],
  );

  static const saleOrder = ScreenConfig(
    model: 'sale.order',
    title: 'Sales Orders',
    icon: Icons.shopping_cart_outlined,
    color: Colors.orange,
    listFields: ['partner_id', 'amount_total', 'state'],
    sections: [
      SectionDef(title: 'Order Info', icon: Icons.receipt_long_outlined, fields: [
        FieldDef(name: 'partner_id', label: 'Customer', icon: Icons.person_outline),
        FieldDef(name: 'date_order', label: 'Date', icon: Icons.calendar_today, type: 'datetime'),
        FieldDef(name: 'amount_total', label: 'Total', icon: Icons.attach_money, type: 'monetary'),
        FieldDef(name: 'state', label: 'Status', icon: Icons.info_outline, type: 'selection'),
      ]),
    ],
    actions: [],
  );

  static const crm = ScreenConfig(
    model: 'crm.lead',
    title: 'CRM',
    icon: Icons.business_center_outlined,
    color: Colors.purple,
    listFields: ['partner_id', 'expected_revenue', 'stage_id'],
    sections: [
      SectionDef(title: 'Opportunity', icon: Icons.trending_up, fields: [
        FieldDef(name: 'partner_id', label: 'Customer', icon: Icons.person_outline),
        FieldDef(name: 'expected_revenue', label: 'Expected Revenue', icon: Icons.attach_money, type: 'monetary'),
        FieldDef(name: 'probability', label: 'Probability', icon: Icons.pie_chart_outline, type: 'float'),
        FieldDef(name: 'stage_id', label: 'Stage', icon: Icons.flag_outlined, type: 'selection'),
      ]),
    ],
    actions: [],
  );

  static const invoice = ScreenConfig(
    model: 'account.move',
    title: 'Invoices',
    icon: Icons.receipt_long_outlined,
    color: Colors.green,
    listFields: ['partner_id', 'amount_total', 'state'],
    sections: [
      SectionDef(title: 'Invoice Info', icon: Icons.description_outlined, fields: [
        FieldDef(name: 'partner_id', label: 'Customer', icon: Icons.person_outline),
        FieldDef(name: 'invoice_date', label: 'Date', icon: Icons.calendar_today, type: 'date'),
        FieldDef(name: 'amount_total', label: 'Total', icon: Icons.attach_money, type: 'monetary'),
        FieldDef(name: 'state', label: 'Status', icon: Icons.info_outline, type: 'selection'),
      ]),
    ],
    actions: [],
  );

  static const stock = ScreenConfig(
    model: 'stock.picking',
    title: 'Stock',
    icon: Icons.inventory_2_outlined,
    color: Colors.cyan,
    listFields: ['partner_id', 'scheduled_date', 'state'],
    sections: [
      SectionDef(title: 'Picking', icon: Icons.inventory_2_outlined, fields: [
        FieldDef(name: 'partner_id', label: 'Partner', icon: Icons.person_outline),
        FieldDef(name: 'scheduled_date', label: 'Scheduled Date', icon: Icons.calendar_today, type: 'datetime'),
        FieldDef(name: 'state', label: 'Status', icon: Icons.info_outline, type: 'selection'),
      ]),
    ],
    actions: [],
  );

  static const project = ScreenConfig(
    model: 'project.project',
    title: 'Projects',
    icon: Icons.assignment_outlined,
    color: Colors.indigo,
    listFields: ['partner_id', 'date_start', 'state'],
    sections: [
      SectionDef(title: 'Project', icon: Icons.assignment_outlined, fields: [
        FieldDef(name: 'partner_id', label: 'Customer', icon: Icons.person_outline),
        FieldDef(name: 'date_start', label: 'Start Date', icon: Icons.calendar_today, type: 'date'),
        FieldDef(name: 'date', label: 'End Date', icon: Icons.calendar_today, type: 'date'),
        FieldDef(name: 'state', label: 'Status', icon: Icons.info_outline, type: 'selection'),
      ]),
    ],
    actions: [],
  );

  static const purchase = ScreenConfig(
    model: 'purchase.order',
    title: 'Purchases',
    icon: Icons.local_shipping_outlined,
    color: Colors.brown,
    listFields: ['partner_id', 'amount_total', 'state'],
    sections: [
      SectionDef(title: 'Purchase', icon: Icons.receipt_long_outlined, fields: [
        FieldDef(name: 'partner_id', label: 'Vendor', icon: Icons.business_outlined),
        FieldDef(name: 'date_order', label: 'Date', icon: Icons.calendar_today, type: 'datetime'),
        FieldDef(name: 'amount_total', label: 'Total', icon: Icons.attach_money, type: 'monetary'),
        FieldDef(name: 'state', label: 'Status', icon: Icons.info_outline, type: 'selection'),
      ]),
    ],
    actions: [],
  );

  static const manufacturing = ScreenConfig(
    model: 'mrp.production',
    title: 'Manufacturing',
    icon: Icons.precision_manufacturing_outlined,
    color: Colors.red,
    listFields: ['product_id', 'date_planned_start', 'state'],
    sections: [
      SectionDef(title: 'Production', icon: Icons.precision_manufacturing_outlined, fields: [
        FieldDef(name: 'product_id', label: 'Product', icon: Icons.inventory_2_outlined),
        FieldDef(name: 'product_qty', label: 'Quantity', icon: Icons.numbers, type: 'float'),
        FieldDef(name: 'date_planned_start', label: 'Start Date', icon: Icons.calendar_today, type: 'datetime'),
        FieldDef(name: 'state', label: 'Status', icon: Icons.info_outline, type: 'selection'),
      ]),
    ],
    actions: [],
  );

  static const events = ScreenConfig(
    model: 'event.event',
    title: 'Events',
    icon: Icons.event_outlined,
    color: Colors.pink,
    listFields: ['date_begin', 'date_end', 'stage_id'],
    sections: [
      SectionDef(title: 'Event Info', icon: Icons.event_outlined, fields: [
        FieldDef(name: 'date_begin', label: 'Start', icon: Icons.calendar_today, type: 'datetime'),
        FieldDef(name: 'date_end', label: 'End', icon: Icons.calendar_today, type: 'datetime'),
        FieldDef(name: 'stage_id', label: 'Stage', icon: Icons.flag_outlined, type: 'selection'),
      ]),
    ],
    actions: [],
  );

  static const notes = ScreenConfig(
    model: 'note.note',
    title: 'Notes',
    icon: Icons.sticky_note_2_outlined,
    color: Colors.amber,
    listFields: ['memo'],
    sections: [
      SectionDef(title: 'Note', icon: Icons.sticky_note_2_outlined, fields: [
        FieldDef(name: 'memo', label: 'Content', icon: Icons.notes, type: 'text'),
      ]),
    ],
    actions: [],
  );

  static const documents = ScreenConfig(
    model: 'documents.document',
    title: 'Documents',
    icon: Icons.folder_outlined,
    color: Colors.grey,
    listFields: ['partner_id'],
    sections: [
      SectionDef(title: 'Info', icon: Icons.folder_outlined, fields: [
        FieldDef(name: 'partner_id', label: 'Partner', icon: Icons.person_outline),
      ]),
    ],
    actions: [],
  );

  static const Map<String, ScreenConfig> all = {
    'contacts': contacts,
    'crm': crm,
    'sale': saleOrder,
    'account': invoice,
    'stock': stock,
    'purchase': purchase,
    'project': project,
    'hr': employees,
    'mrp': manufacturing,
    'event': events,
    'note': notes,
    'documents': documents,
    'point_of_sale': ScreenConfig(
      model: 'pos.order',
      title: 'POS',
      icon: Icons.point_of_sale_outlined,
      color: Colors.deepPurple,
      listFields: ['partner_id', 'amount_total', 'state'],
      sections: [
        SectionDef(title: 'Order', icon: Icons.receipt_outlined, fields: [
          FieldDef(name: 'partner_id', label: 'Customer', icon: Icons.person_outline),
          FieldDef(name: 'amount_total', label: 'Total', icon: Icons.attach_money, type: 'monetary'),
          FieldDef(name: 'state', label: 'Status', icon: Icons.info_outline, type: 'selection'),
        ]),
      ],
      actions: [],
    ),
  };
}
