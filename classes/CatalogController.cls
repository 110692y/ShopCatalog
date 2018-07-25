public class CatalogController {

    public Boolean newOrder { get; set; }
    public Order__c order { get; set; }
    public List<ShopItem__c> shopItems { get; set; }
    public List<Cart_Item__c> cartItems { get; set; }
    public Cart_Item__c newCart_item { get; set; }
    public String selectedItem { get; set; }
    public Set<String> cartItemNames { get; set; }
    public Boolean emptyCart {get;set;}
    public Boolean seeCart {get;set;}

    public CatalogController() {
        seeCart = false;
        emptyCart = true;
        order = new Order__c(Name = 'Order # ' + System.now());
        cartItemNames = new Set<String>();
        shopItems = [SELECT ID, Name, Price__c, ImageURL__c, Description__c FROM ShopItem__c];
        loadCart();
    }

    public void showCart() {
        if (seeCart == false) {
            seeCart = true;
        }
    }

    public void hideCart() {
        if (seeCart == true) {
            seeCart = false;
        }
    }

    public void createNewOrder() {
        newOrder = true;
        insert order;
    }

    public void loadCart() {
        cartItemNames.add('check');
        if (order.id != null) {
            cartItems = [SELECT Id, Shop_Item__c, Shop_Item__r.Name, Name, Amount__c, Sum__c FROM Cart_Item__c WHERE Shop_Order__c = :order.Id];
            if (cartItems.size()>0) {
                changeValue();
            }
            for (Cart_Item__c CI : cartItems) {
                cartItemNames.add(CI.Shop_Item__r.Name);
            }
        }

    }

    public void changeValue() {
        emptyCart = false;
    }

    public void addToCart() {
        if (selectedItem == null) {
            return;
        }
        for (ShopItem__c ShopItem : shopItems) {
            if (ShopItem.Id == selectedItem) {
                if (!cartItemNames.isEmpty()) {
                    if (!cartItemNames.contains(ShopItem.Name)) {
                        newCart_item = new Cart_Item__c(Shop_Order__c = order.Id, Shop_Item__c = ShopItem.Id, Amount__c = 1);
                        insert newCart_item;
                    } else if (cartItemNames.contains(ShopItem.Name)) {
                        for (Cart_Item__c cartItem : cartItems) {
                            if (ShopItem.Name == cartItem.Shop_Item__r.Name) {
                                cartItem.Amount__c += 1;
                                update cartItem;
                            }
                        }
                    }
                } else {
                    newCart_item = new Cart_Item__c(Shop_Order__c = order.Id, Shop_Item__c = ShopItem.Id, Amount__c = 1);
                    insert newCart_item;
                }
            }
        }
        loadCart();
    }
}