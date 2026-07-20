Physical properties (owned/managed) that projects and estimates are tied to.
CREATE TABLE public.properties (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  property_name text NOT NULL,
  address text NOT NULL,
  city text NOT NULL,
  state text DEFAULT 'WA'::text,
  zip text,
  owner_name text NOT NULL,
  owner_email text,
  owner_phone text,
  property_type text NOT NULL,
  notes text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT properties_pkey PRIMARY KEY (id)
);
_____________________________________________________________
Suppliers/vendors used for purchasing materials.
CREATE TABLE public.vendors (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  location text,
  contact_info text,
  reliability_score numeric,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT vendors_pkey PRIMARY KEY (id)
);
_____________________________________________________________
Material/Product Catalo.g
CREATE TABLE public.items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  category text,
  unit_type text NOT NULL,
  standard_unit_size numeric,
  description text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  subcategory text,
  part_number text,
  CONSTRAINT items_pkey PRIMARY KEY (id)
);
_____________________________________________________________
Alternate names for items (e.g. vendor-specific naming) to aid receipt matching.
  CREATE TABLE public.item_aliases (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  item_id uuid NOT NULL,
  alias text NOT NULL,
  CONSTRAINT item_aliases_pkey PRIMARY KEY (id),
  CONSTRAINT item_aliases_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(id)
);
_____________________________________________________________
Labor roster with cost and billing rates. billing_rate auto-computes as 2× the hourly cost rate, clamped to $125–$175/hr.
  CREATE TABLE public.labor (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  position text NOT NULL,
  hourly_rate numeric NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  billing_rate numeric DEFAULT LEAST(GREATEST((hourly_rate * (2)::numeric), (125)::numeric), (175)::numeric),
  CONSTRAINT labor_pkey PRIMARY KEY (id)
);
_____________________________________________________________
Job-Site consumables (non-catalog materials) with a flat unit cost. 
CREATE TABLE public.consumables (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  name text NOT NULL,
  category text NOT NULL,
  unit_cost numeric NOT NULL,
  unit_type text DEFAULT 'each'::text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT consumables_pkey PRIMARY KEY (id)
);
______________________________________________________________
work performaned at a paroperty, tracked with budget and status 
CREATE TABLE public.projects (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  project_name text NOT NULL,
  project_type text NOT NULL,
  property_id uuid,
  property_name text,
  status text DEFAULT 'active'::text,
  start_date date,
  end_date date,
  budget numeric,
  notes text,
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT projects_pkey PRIMARY KEY (id),
  CONSTRAINT projects_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
______________________________________________________________
Client-facing cost estimates
CREATE TABLE public.estimates (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  client_name text,
  project_type text,
  source text,
  total_cost numeric,
  status text DEFAULT 'draft'::text,
  created_at timestamp with time zone DEFAULT now(),
  material_cost numeric DEFAULT 0,
  labor_cost numeric DEFAULT 0,
  margin_percent numeric DEFAULT 20,
  final_price numeric,
  property_id uuid,
  CONSTRAINT estimates_pkey PRIMARY KEY (id),
  CONSTRAINT estimates_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id)
);
_______________________________________________________________
Material line items within an estimate. Total_cost auto-computes as quantity x unit_price
CREATE TABLE public.estimate_line_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  estimate_id uuid NOT NULL,
  item_id uuid NOT NULL,
  quantity numeric NOT NULL,
  unit_price numeric NOT NULL,
  total_cost numeric DEFAULT (quantity * unit_price),
  source text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT estimate_line_items_pkey PRIMARY KEY (id),
  CONSTRAINT estimate_line_items_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.estimates(id),
  CONSTRAINT estimate_line_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(id)
);
_____________________________________________________________
labor line items within an estimate. cost_total/bill_total auto-compute from hours x rate
CREATE TABLE public.estimate_labor (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  estimate_id uuid NOT NULL,
  labor_id uuid NOT NULL,
  hours numeric NOT NULL CHECK (hours > 0::numeric),
  cost_rate numeric NOT NULL,
  bill_rate numeric NOT NULL,
  cost_total numeric DEFAULT (hours * cost_rate),
  bill_total numeric DEFAULT (hours * bill_rate),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT estimate_labor_pkey PRIMARY KEY (id),
  CONSTRAINT estimate_labor_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.estimates(id),
  CONSTRAINT estimate_labor_labor_id_fkey FOREIGN KEY (labor_id) REFERENCES public.labor(id)
);
_____________________________________________________________
Consumables line items within an estimate
  CREATE TABLE public.estimate_consumables (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  estimate_id uuid NOT NULL,
  consumable_id uuid NOT NULL,
  quantity numeric NOT NULL DEFAULT 1 CHECK (quantity > 0::numeric),
  unit_cost numeric NOT NULL,
  total numeric DEFAULT (quantity * unit_cost),
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT estimate_consumables_pkey PRIMARY KEY (id),
  CONSTRAINT estimate_consumables_estimate_id_fkey FOREIGN KEY (estimate_id) REFERENCES public.estimates(id),
  CONSTRAINT estimate_consumables_consumable_id_fkey FOREIGN KEY (consumable_id) REFERENCES public.consumables(id)
);
______________________________________________________________
Upload recipt files (invoices/photos) pending or completed processing 
CREATE TABLE public.receipts (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  vendor_id uuid,
  file_url text NOT NULL,
  file_type text,
  processed boolean DEFAULT false,
  processing_status text DEFAULT 'pending'::text,
  created_at timestamp with time zone DEFAULT now(),
  property_id uuid,
  purchase_date date,
  extracted_total numeric,
  vendor_detected text,
  purchase_type text DEFAULT 'property'::text,
  project_id uuid,
  CONSTRAINT receipts_pkey PRIMARY KEY (id),
  CONSTRAINT receipts_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id),
  CONSTRAINT receipts_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id),
  CONSTRAINT receipts_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id)
);
_______________________________________________________________
individual line items extracted from a recipt with ai suggestions and human reviewed matches 
CREATE TABLE public.receipt_line_items (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  receipt_id uuid NOT NULL,
  raw_name text NOT NULL,
  extracted_quantity numeric NOT NULL DEFAULT 1,
  extracted_total_price numeric NOT NULL DEFAULT 0,
  extracted_unit_price numeric DEFAULT (extracted_total_price / NULLIF(extracted_quantity, (0)::numeric)),
  extracted_unit_type text DEFAULT 'each'::text,
  matched_item_id uuid,
  matched_item_name text,
  confidence_level numeric DEFAULT 0.5,
  status text DEFAULT 'pending'::text,
  reviewed_at timestamp with time zone,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  suggested_category text,
  suggested_subcategory text,
  suggested_item_name text,
  suggested_unit_type text,
  extracted_part_number text,
  extracted_description text,
  suggested_part_number text,
  suggested_description text,
  CONSTRAINT receipt_line_items_pkey PRIMARY KEY (id),
  CONSTRAINT receipt_line_items_receipt_id_fkey FOREIGN KEY (receipt_id) REFERENCES public.receipts(id),
  CONSTRAINT receipt_line_items_matched_item_id_fkey FOREIGN KEY (matched_item_id) REFERENCES public.items(id)
);
______________________________________________________
The "Price Bible" — historical price records per item/vendor, sourced from receipts, used to inform estimating.
  CREATE TABLE public.price_recordsbible (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  item_id uuid NOT NULL,
  vendor_id uuid NOT NULL,
  receipt_id uuid,
  raw_price numeric NOT NULL,
  quantity numeric NOT NULL,
  unit_cost numeric DEFAULT (raw_price / NULLIF(quantity, (0)::numeric)),
  unit_type text NOT NULL,
  purchase_date date,
  confidence_level numeric DEFAULT 0.5,
  is_verified boolean DEFAULT false,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT price_recordsbible_pkey PRIMARY KEY (id),
  CONSTRAINT price_records_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(id),
  CONSTRAINT price_records_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id),
  CONSTRAINT price_records_receipt_id_fkey FOREIGN KEY (receipt_id) REFERENCES public.receipts(id)
);
____________________________________________________
Posted accounting record generated per processed receipt — a denormalized summary for bookkeeping/export.
CREATE TABLE public.accounting_log (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  receipt_id uuid,
  vendor_id uuid,
  vendor_name text,
  vendor_detected text,
  property_id uuid,
  property_name text,
  purchase_date date,
  logged_at timestamp with time zone DEFAULT now(),
  receipt_total numeric,
  line_item_count integer DEFAULT 0,
  category_breakdown jsonb,
  file_storage_path text,
  file_type text,
  status text DEFAULT 'posted'::text,
  notes text,
  created_at timestamp with time zone DEFAULT now(),
  purchase_type text DEFAULT 'property'::text,
  project_id uuid,
  project_name text,
  CONSTRAINT accounting_log_pkey PRIMARY KEY (id),
  CONSTRAINT accounting_log_receipt_id_fkey FOREIGN KEY (receipt_id) REFERENCES public.receipts(id),
  CONSTRAINT accounting_log_vendor_id_fkey FOREIGN KEY (vendor_id) REFERENCES public.vendors(id),
  CONSTRAINT accounting_log_property_id_fkey FOREIGN KEY (property_id) REFERENCES public.properties(id),
  CONSTRAINT accounting_log_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id)
);
____________________________________________________
