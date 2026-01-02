# Salad Shop Inventory Management System

A full-stack inventory management system for a salad shop, built with Elixir/Phoenix backend and React/TypeScript frontend. Track ingredients, manage stock levels, and monitor inventory movements for your salad business.

## Tech Stack

- **Backend**: Elixir + Phoenix (JSON API), PostgreSQL
- **Frontend**: React + TypeScript
- **Testing**: ExUnit (backend tests)

## Project Structure

```
.
├── backend/          # Phoenix application
│   ├── lib/
│   │   ├── inventory_management/          # Core business logic
│   │   │   ├── inventory/                 # Inventory context
│   │   │   │   ├── item.ex               # Item schema
│   │   │   │   └── movement.ex           # Movement schema
│   │   │   └── inventory.ex              # Inventory context (business logic)
│   │   └── inventory_management_web/      # Web layer
│   │       ├── controllers/              # API controllers
│   │       └── views/                    # JSON views
│   ├── priv/repo/migrations/             # Database migrations
│   └── test/                             # ExUnit tests
└── frontend/         # React application
    └── src/
        ├── components/                    # React components
        └── types.ts                      # TypeScript types
```

## Data Model

### Item
- `id`: Integer (primary key)
- `name`: String (required)
- `sku`: String (required, unique)
- `unit`: String (required, one of: "pcs", "kg", "litre")
- `inserted_at`: Timestamp
- `updated_at`: Timestamp

### Inventory Movement
- `id`: Integer (primary key)
- `item_id`: Integer (foreign key to items)
- `quantity`: Integer (required, must be positive)
- `movement_type`: String (required, one of: "IN", "OUT", "ADJUSTMENT")
- `inserted_at`: Timestamp
- `updated_at`: Timestamp

## Stock Calculation Logic

**Important**: Stock is **not stored directly** in the database. It is calculated on-the-fly from inventory movements.

### Formula
```
Stock = sum(IN movements) - sum(OUT movements) + sum(ADJUSTMENT movements)
```

### Movement Types
- **IN**: Adds to stock (positive quantity)
- **OUT**: Subtracts from stock (positive quantity)
- **ADJUSTMENT**: Can add or subtract (positive or negative quantity)

### Example (Salad Shop - Romaine Lettuce)
```
Initial: 0 kg
+ IN: 50 kg (new delivery) → Stock = 50 kg
- OUT: 12 kg (used for salads) → Stock = 38 kg
+ IN: 30 kg (new delivery) → Stock = 68 kg
+ ADJUSTMENT: +2 kg (found extra stock) → Stock = 70 kg
- OUT: 15 kg (used for salads) → Stock = 55 kg
```

### Negative Stock Prevention
The system **prevents negative stock** by:
1. Validating stock after each movement creation
2. Rolling back the movement if it would result in negative stock
3. Returning a clear error message: "Stock cannot be negative. Current stock would be: X"

## Backend APIs

### Items

#### GET /api/items
Fetch all items with current stock.

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Romaine Lettuce",
      "sku": "LET-ROMA-001",
      "unit": "kg",
      "stock": 25,
      "inserted_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

#### POST /api/items
Create a new item.

**Request:**
```json
{
  "item": {
    "name": "Cherry Tomatoes",
    "sku": "TOM-CHERRY-001",
    "unit": "kg"
  }
}
```

#### GET /api/items/:id
Get a specific item with current stock.

#### PUT /api/items/:id
Update an item.

#### DELETE /api/items/:id
Delete an item.

### Movements

#### POST /api/items/:id/movements
Record an inventory movement.

**Request:**
```json
{
  "movement": {
    "quantity": 10,
    "movement_type": "IN"
  }
}
```

**Response (Success):**
```json
{
  "data": {
    "id": 1,
    "item_id": 1,
    "quantity": 10,
    "movement_type": "IN",
    "inserted_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-01T00:00:00Z"
  }
}
```

**Response (Error - Negative Stock):**
```json
{
  "error": "Stock cannot be negative. Current stock would be: -5"
}
```

#### GET /api/items/:id/movements
Get movement history for an item.

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "item_id": 1,
      "quantity": 10,
      "movement_type": "IN",
      "inserted_at": "2024-01-01T00:00:00Z",
      "updated_at": "2024-01-01T00:00:00Z"
    }
  ]
}
```

## How to Run the Project

### Prerequisites
- Elixir 1.14+ and Erlang/OTP 25+
- PostgreSQL 12+
- Node.js 18+ and npm
- Mix (comes with Elixir)

### Backend Setup

1. Navigate to the backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
mix deps.get
```

3. Create and setup the database:
```bash
mix ecto.create
mix ecto.migrate
```

4. (Recommended) Seed the database with sample salad shop items:
```bash
mix run priv/repo/seeds.exs
```
This will create sample ingredients like lettuce, tomatoes, cucumbers, etc. with initial stock levels.

5. Start the Phoenix server:
```bash
mix phx.server
```

The API will be available at `http://localhost:4000`

### Frontend Setup

1. Navigate to the frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
npm install
```

3. Start the development server:
```bash
npm start
```

The frontend will be available at `http://localhost:3000`

### Running Tests

#### Backend Tests
```bash
cd backend
mix test
```

The test suite includes:
- Stock calculation tests
- Negative stock rejection tests
- Item and movement CRUD tests

## Frontend Features

### Item List
- Displays all salad shop ingredients with current stock
- Click on an ingredient to view details
- Highlights low stock items (< 10 units) - helps prevent running out of ingredients during service

### Create Item Form
- Add new ingredients with name, SKU, and unit
- Validates required fields and unit type
- Perfect for adding new ingredients to your inventory

### Inventory Movement Form
- Record IN (deliveries), OUT (usage), or ADJUSTMENT (corrections) movements
- Validates quantity and prevents negative stock (can't use what you don't have)
- Shows current stock for selected ingredient

### Item Detail View
- View ingredient information and current stock
- Display complete movement history (track all deliveries and usage)
- Record new movements from detail view

## Assumptions

1. **Stock Calculation**: Stock is always calculated from movements, never stored directly
2. **Negative Stock**: Not allowed - system rejects movements that would result in negative stock (prevents selling ingredients you don't have)
3. **Movement Quantity**: Must be positive for IN/OUT, can be positive or negative for ADJUSTMENT
4. **SKU Uniqueness**: Each ingredient must have a unique SKU
5. **Unit Types**: Three unit types supported:
   - `kg` - for vegetables, fruits, cheese, etc. (e.g., lettuce, tomatoes)
   - `litre` - for liquids (e.g., olive oil, vinegar, dressings)
   - `pcs` - for packaged items (e.g., croutons, packaged ingredients)
6. **Transaction Safety**: Movement creation is atomic - if stock validation fails, the movement is rolled back
7. **Salad Shop Context**: Designed for tracking fresh ingredients and supplies for a salad business

## Improvements & Future Enhancements

1. **Expiration Dates**: Track expiration dates for fresh ingredients (critical for salad shop)
2. **Low Stock Alerts**: Email/notification system when ingredients run low
3. **Supplier Management**: Track suppliers and delivery schedules
4. **Recipe Integration**: Link ingredients to menu items/recipes, calculate required stock
5. **Daily Usage Reports**: Track daily ingredient usage patterns
6. **Waste Tracking**: Record spoiled/wasted ingredients with reasons
7. **Cost Tracking**: Track ingredient costs and calculate profit margins
8. **Seasonal Items**: Mark seasonal ingredients, suggest alternatives
9. **Multi-location**: Support for multiple shop locations or kitchen/prep areas
10. **Barcode Scanning**: Add barcode scanning for quick stock updates
11. **Mobile App**: Mobile app for kitchen staff to update stock in real-time
12. **Integration with POS**: Integrate with point-of-sale system for automatic stock deductions
13. **Authentication & Authorization**: User roles (manager, chef, staff) with different permissions
14. **API Documentation**: Add Swagger/OpenAPI documentation
15. **Docker Support**: Containerize the application for easy deployment

## Development Notes

- The backend uses Ecto for database operations
- Stock calculation happens in the `Inventory.calculate_stock/1` function
- Negative stock validation occurs in `Inventory.validate_stock/1`
- CORS is enabled for frontend-backend communication
- The frontend uses React hooks for state management
- API errors are displayed to users with clear messages

## License

ISC
