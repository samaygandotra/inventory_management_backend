# Script for populating the database with salad shop inventory items
#
# Run it with: mix run priv/repo/seeds.exs

alias InventoryManagement.Repo
alias InventoryManagement.Inventory
alias InventoryManagement.Inventory.Item

# Create sample salad shop items
items = [
  %{name: "Romaine Lettuce", sku: "LET-ROMA-001", unit: "kg"},
  %{name: "Cherry Tomatoes", sku: "TOM-CHERRY-001", unit: "kg"},
  %{name: "Cucumber", sku: "CUC-001", unit: "kg"},
  %{name: "Red Bell Pepper", sku: "PEP-RED-001", unit: "kg"},
  %{name: "Feta Cheese", sku: "CHS-FETA-001", unit: "kg"},
  %{name: "Olive Oil", sku: "OIL-OLIVE-001", unit: "litre"},
  %{name: "Balsamic Vinegar", sku: "VIN-BAL-001", unit: "litre"},
  %{name: "Croutons", sku: "CRT-001", unit: "pcs"}
]

IO.puts("Creating salad shop inventory items...")

Enum.each(items, fn item_attrs ->
  case Inventory.create_item(item_attrs) do
    {:ok, item} ->
      IO.puts("  ✓ Created: #{item.name} (#{item.sku})")
      
      # Add some initial stock movements for demonstration
      case Inventory.create_movement(%{
        item_id: item.id,
        quantity: case item.unit do
          "kg" -> 20
          "litre" -> 10
          "pcs" -> 50
        end,
        movement_type: "IN"
      }) do
        {:ok, _movement} ->
          IO.puts("    → Added initial stock")
        {:error, _} ->
          IO.puts("    → Skipped initial stock")
      end
      
    {:error, changeset} ->
      IO.puts("  ✗ Failed to create: #{item_attrs.name}")
      IO.inspect(changeset.errors)
  end
end)

IO.puts("\nSeed data created successfully!")
