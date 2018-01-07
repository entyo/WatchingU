import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { ItemCardListComponent } from './item-card-list.component';

describe('ItemCardListComponent', () => {
  let component: ItemCardListComponent;
  let fixture: ComponentFixture<ItemCardListComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ ItemCardListComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(ItemCardListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
