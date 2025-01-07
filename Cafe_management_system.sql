CREATE TABLE Menu (
    menu_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2),
    popularity INT DEFAULT 0
);


CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    menu_id INT,
    quantity INT,
    order_date DATE,
    FOREIGN KEY (menu_id) REFERENCES Menu(menu_id)
);


CREATE TABLE Inventory (
    inventory_id INT PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    quantity INT
);

CREATE TABLE Staff (
    staff_id INT PRIMARY KEY,
    name VARCHAR(100),
    role VARCHAR(50),
    availability VARCHAR(50)
);

CREATE TABLE Shifts (
    shift_id INT PRIMARY KEY,
    staff_id INT,
    shift_time VARCHAR2(50),
    shift_date DATE,
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

CREATE TABLE Notifications (
    notification_id INT PRIMARY KEY,
    message VARCHAR(255),
    inventory_id INT,
    FOREIGN KEY (inventory_id) REFERENCES Inventory(inventory_id)
);

CREATE SEQUENCE notification_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE OR REPLACE TRIGGER notification_trigger
BEFORE INSERT ON Notifications
FOR EACH ROW
BEGIN
    :NEW.notification_id := notification_seq.NEXTVAL;
END;
/
 
CREATE OR REPLACE TRIGGER notify_low_inventory
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    IF :NEW.quantity < 10 THEN
        INSERT INTO Notifications (message, inventory_id) 
        VALUES ('Low Inventory Alert: Restock ' || :NEW.item_name, :NEW.inventory_id);
    END IF;
END;
/

CREATE OR REPLACE TRIGGER notify_restock_inventory
AFTER UPDATE ON Inventory
FOR EACH ROW
BEGIN
    IF :NEW.quantity > :OLD.quantity THEN
        INSERT INTO Notifications (message, inventory_id) 
        VALUES ('Inventory Restocked: ' || :NEW.item_name, :NEW.inventory_id);
    END IF;
END;
/

CREATE SEQUENCE shift_seq
START WITH 1
INCREMENT BY 1
NOCACHE;

CREATE OR REPLACE PROCEDURE schedule_staff_shifts
IS
    peak_hours VARCHAR(50);
BEGIN
    peak_hours := '9 AM - 12 PM';
    FOR staff IN (
        SELECT staff_id, availability 
        FROM Staff 
        WHERE availability LIKE '%Morning%'
    ) LOOP
        INSERT INTO Shifts (shift_id, staff_id, shift_time, shift_date) 
        VALUES (
            shift_seq.NEXTVAL, 
            staff.staff_id,
            peak_hours,
            SYSDATE
        );
    END LOOP;
END;
/

INSERT INTO Staff (staff_id, name, role, availability) 
VALUES (1, 'Alice', 'Chef', 'Morning');

INSERT INTO Staff (staff_id, name, role, availability) 
VALUES (2, 'Bob', 'Waiter', 'Evening');

INSERT INTO Staff (staff_id, name, role, availability) 
VALUES (3, 'Charlie', 'Manager', 'Full Day');

INSERT INTO Inventory (inventory_id, item_name, quantity) 
VALUES (1, 'Coffee Beans', 50);

INSERT INTO Inventory (inventory_id, item_name, quantity) 
VALUES (2, 'Milk', 20);

INSERT INTO Inventory (inventory_id, item_name, quantity) 
VALUES (3, 'Sugar', 100);

INSERT INTO Menu (menu_id, item_name, category, price, popularity) 
VALUES (1, 'Cappuccino', 'Beverages', 120.00, 250);

INSERT INTO Menu (menu_id, item_name, category, price, popularity) 
VALUES (2, 'Espresso', 'Beverages', 90.00, 200);

INSERT INTO Menu (menu_id, item_name, category, price, popularity) 
VALUES (3, 'Brownie', 'Snacks', 150.00, 300);

UPDATE Inventory 
SET quantity = quantity - 10 
WHERE item_name = 'Coffee Beans';

SELECT * FROM Shifts;