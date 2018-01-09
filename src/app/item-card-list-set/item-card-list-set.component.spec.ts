import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ItemCardListSetComponent } from './item-card-list-set.component';

describe('ItemCardListSetComponent', () => {
  let component: ItemCardListSetComponent;
  let fixture: ComponentFixture<ItemCardListSetComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ItemCardListSetComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ItemCardListSetComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
